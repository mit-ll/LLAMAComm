function Latm = atmosphericLoss(tx_xyz, rx_xyz, fghz, atmosphere)
%
%Usage: 
%
%   Latm = atmosphericLoss_nofrec(tx_xyz, rx_xyz, fghz, atmosphere)
%
%Inputs:
%
%   tx_xyz     - Transmitter location (Cartesian coordiates, in meters)
%   rx_xyz     - Reciever location (Cartesian coordiates, in meters)
%   fghz       - Frequency (in GHz)
%   atmosphere - Structure containing fields
%                   latd   - Latitude, in degrees
%                   season - Season. Either "summer" or "winter"
%
%   alt0       - Altitude or coordinate system origin, in meters
%
%Description:
%
%  Computes the atmospheric loss between 2 nodes, given their positions,
% the frequency of interest and atmospheric modeling information.
%
%

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


if nargin < 4
  atmosphere = struct('latd',[], 'season', []);
end

% Airborne parameters   
ds = 100; % Approximate along-line spacing (meters)

nodeDist = norm(rx_xyz - tx_xyz);
if nodeDist == 0
  error('getPathloss doesn''t work on co-located nodes');
end

%xyz = calcPath_norefrac(tx_xyz, rx_xyz, ds);
xyz = calcPath(tx_xyz, rx_xyz, ds, [], []);

hi_km = 1e-3*calcAltitude(xyz, []);

%
if any(hi_km <0)
  Latm = Inf; % Below (geometric) horizon
else
  nPts = size(xyz, 2);
  
  [temperature, pressure, rho] = ITUrefAtmosphere(hi_km, atmosphere.latd, atmosphere.season); 
  gamma = ITUspecificAtten(fghz, temperature, pressure, rho); % dB/km
  
  % Integrate via trapezoidal rule 
  % Note that for non-linear paths, the arc-length increments will be non-constant
  ds_km = 1e-3*sqrt(sum(diff(xyz,1,2).^2, 1));
  Latm = sum(0.5*(gamma(1:nPts-1)+gamma(2:nPts)).*ds_km);  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xyz, info] = calcPath(startPt, endPt, ds, atmosphere, geomInfo)
%
%Usage: 
%
%   xyz = calcPath(startPt, endPt, fghz, atmosphere)
%
%Inputs:
%
%   startPt    - Transmitter location (Cartesian coordiates, in meters)
%   endPt      - Reciever location (Cartesian coordiates, in meters)
%   ds         - Approximate along track point spacing, in meters
%
%Outputs:
%
%   xyz        - 3xN array of points along a path between startPt and endPt.
%                N is always >=3 
%
%Description:
%
%  Computes a light path berween the two specified points, taking refraction into account.
% The path is computed by appealing to Fermat's principal. The path returned is found by 
% an iterative method that solves for the piecewise linear least-time path.
%

% Handle arguments
if nargin < 6
  geomInfo = []; % Default
  if nargin < 5
    atmosphere = [];
  end
end
if isempty(atmosphere)
  atmosphere = struct('latd',[], 'season',[]);
end

% Internal parameters
angleThresh = 1e-4; % (degrees) Closer to vertical that this is treated as vertical
max_nPts = 1001;    % Odd number, >= 3
minIter = 2;        % Minimum number of iterations
maxIter = 5;        % Maximum number of iterations
thresh = 1e-4;      % (meters) Cross-track error covergence criterion
dv = 1;             % (meters) Cross-track step used to estimate refractivity derivative

%
nIter = 0;

%
nodeDist = norm(endPt - startPt);
nPts = min(max_nPts, 3 + 2*floor(nodeDist/abs(ds)/2)); % Odd number, >= 3
if nodeDist==0
  xyz = repmat(startPt, [1, nPts]);
  if nargout > 1    
    info.u = zeros(1, nPts);
    info.v = zeros(1, nPts);
    info.uhat = zeros(3,1);
    info.vhat = zeros(3,1);
    info.up = calcLocalup(startPt);
    info.nPts = nPts;
    info.nIter = nIter;
  end
  return;
end

uhat = (endPt - startPt)/nodeDist;      % Along-track unit vector
up = calcLocalup(startPt);

u = linspace(0, nodeDist, nPts);        % Along-track curve paramter (m)
xyz0 = startPt*ones(1,nPts) + uhat*u;    % XYZ of points on the straight-line path
deltau = nodeDist/(nPts-1);             % Along track spacing (m)
deltau2 = deltau.^2;                    %

xyz = xyz0; % Initially just on the straight line path

dotProd = uhat'*up;
dotProd(dotProd>1)=1; % In case of numerical issues
vhat = up - (uhat*dotProd);

v = zeros(1,nPts);                     % Cross-track coordinates

angle=acosd(dotProd);
if angle > angleThresh && angle < 180-angleThresh

  vhat = vhat/norm(vhat);                 % Cross-track unit vector
  v0 = Inf + v;
  while((nIter < minIter) || ((nIter < maxIter) && max(abs(v-v0)) > thresh))
    
    nIter = nIter + 1;
    L = sqrt(deltau2 + (diff(v).^2));
    
    % Estimate index of refraction and cross-track derivatives 
    hi_km = 1e-3*calcAltitude(xyz, geomInfo);
    [temperature, pressure, rho] = ITUrefAtmosphere(hi_km, atmosphere.latd, atmosphere.season); 
    N1 = refractivity(temperature, pressure, rho);
    
    hi_km2 = 1e-3*calcAltitude(xyz + (dv*vhat)*ones(1,nPts), geomInfo);
    [temperature2, pressure2, rho2] = ITUrefAtmosphere(hi_km2, atmosphere.latd, atmosphere.season); 
    N2 = refractivity(temperature2, pressure2, rho2);  

    dn = 1e-6*(N2-N1)/dv; % Cross-track derivative of index of refraction at each point
    n = 1 + 1e-6*N1; % Index of refraction at each point
    
    v0 = v; % Save
    
    % Solve tridiagonal system
    w = (n(2:nPts)+n(1:nPts-1))./L;
    D = -(w(1:nPts-2)+w(2:nPts-1)); % Diagonal terms
    O = w(2:nPts-2); % Off diagonal
    Q = (L(1:nPts-2) + L(2:nPts-1)).*dn(2:nPts-1); 
    v(2:nPts-1) = solveTridiag(D, O, O, Q).';

    % Update coordinates
    xyz = xyz0 + (vhat*v);
  end
else
  vhat = zeros(3,1);
  nIter = 0;
end

if nargout > 1
  info.u = u;
  info.v = v;
  info.uhat = uhat;
  info.vhat = vhat;
  info.up = up;
  info.nPts = nPts;
  info.nIter = nIter;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xyz = calcPath_norefrac(startPt, endPt, ds); %#ok if unused
%
%Usage: 
%
%   xyz = atmosphericLoss_nofrec(startPt, endPt, fghz, atmosphere)
%
%Inputs:
%
%   startPt    - Transmitter location (Cartesian coordiates, in meters)
%   endPt      - Reciever location (Cartesian coordiates, in meters)
%   ds         - Approximate along track point spacing, in meters
%
%Outputs:
%
%   xyz        - 3xN array of points along a path between startPt and endPt.
%                N is always >=3 
%
%Description:
%
%  Computes a light path berween the two specified points, neglecting refraction.
% (This is just  a straight line)
%

% Handle arguments
if  nargin < 3
  ds = 100; % Approximate along-line spacing (meters)
end

% Internal Parameters
max_nPts = 1001;

%
nodeDist = norm(endPt - startPt);
nPts = min(max_nPts, 3 + 2*floor(nodeDist/abs(ds)/2)); % Odd number, >= 3
u = (endPt - startPt)/nodeDist;         % Unit vector on straight line path
s = linspace(0, nodeDist, nPts);        % Along-path distances (m)
xyz = startPt*ones(1,nPts) + u*s;        % XYZ of points on the path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hi = calcAltitude(xyz, geomInfo)
%
%Usage:
%
%   hi = calcAltitude(XYZ, geomInfo)
%
%Description:
%
%   Computes the altitude (in meters) given 3xN coordinates XYZ.
% The method of calculation is controlled by 'geomInfo'
%
%
if nargin < 2 || isempty(geomInfo) || ~isstruct(geomInfo)
  geomInfo = [];
  geomInfo.type = 'spherical';
  geomInfo.Re = 6371.0088e3; % Earth radius, in meters (IUGG)    
  geomInfo.alt0 = 0; % Altitude of the coordinate system origin
  geomInfo.up = [0;0;1]; % Unit vector in local "up" direction at the origin
end

nPts = size(xyz, 2);
switch(geomInfo.type)  
  case 'spherical'
    earthCenter = -(geomInfo.Re + geomInfo.alt0)*geomInfo.up;
    hi = (sqrt(sum((xyz-earthCenter*ones(1, nPts)).^2))-geomInfo.Re); % Altitude (km)(spherical earth)    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uhat = calcLocalup(xyz, geomInfo)
%
%Usage:
%
%   uhat = calcLocalUp(XYZ, geomInfo)
%
%Description:
%
%   Computes the local up direction altitude given 3xN coordinates XYZ.
%
%
if nargin < 2 || isempty(geomInfo) || ~isstruct(geomInfo)
  geomInfo.type = 'spherical';
  geomInfo.Re = 6371.0088e3; % Earth radius, in meters (IUGG)    
  geomInfo.alt0 = 0; % Altitude of the coordinate system origin
  geomInfo.up = [0;0;1]; % Unit vector in local "up" direction at the origin
end

nPts = size(xyz, 2);
switch(geomInfo.type)  
  case 'spherical'
    earthCenter = -(geomInfo.Re + geomInfo.alt0)*geomInfo.up;
    fromCenter = (xyz-earthCenter*ones(1, nPts));
    D = sqrt(sum(fromCenter.^2, 1));
    uhat = fromCenter./(ones(3,1)*D);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = solveTridiag(diagonal, upper, below, y)
%
%
%Usage:
%
%  x = solveTriadiag(DIAGONAL, UPPER, BELOW, y)
%
%Description:
%
% Efficiently solves the tridiagonal system Ax = y where A has a diagonal 
% DIAGONAL, upper diagonal UPPER and below diagonal BELOW
% 

nDim = numel(y);
x = zeros(nDim, 1);
work = zeros(nDim, 1);
weight = diagonal(1);
x(1) = y(1)/weight;

% Forward elimination
for ii = 1:nDim-1
  work(ii) = upper(ii)/weight;
  weight = diagonal(ii+1) - below(ii)*work(ii);
  x(ii+1) = (y(ii+1) - below(ii)*x(ii))/weight;
end

% Backsubstitution
for ii = (nDim-1):-1:1
  x(ii) = x(ii) - work(ii)*x(ii+1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.
