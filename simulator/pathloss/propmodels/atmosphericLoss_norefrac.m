function Latm = atmosphericLoss_norefrac(tx_xyz, rx_xyz, fghz, atmosphere, alt0)
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

if nargin < 5
  alt0 = 0; % Ground height, in meters
  if nargin < 4
    atmosphere = struct('latd',[], 'season', []);
  end
end

% Airborne parameters   
Re = 6371.0088e3; % Earth radius, in meters (IUGG)
ds = 100; % Approximate along-line spacing (meters)

nodeDist = norm(rx_xyz - tx_xyz);
if nodeDist == 0
  error('getPathloss doesn''t work on co-located nodes');
end

nPts = 3 + 2*floor(nodeDist/ds/2);      % Odd number, >= 3        
u = (rx_xyz - tx_xyz)/nodeDist;         % Unit vector on straight line path
s = linspace(0, nodeDist, nPts);        % Along-path distances (m)
xyz = tx_xyz*ones(1,nPts) + u*s;        % XYZ of points on the path


% This altitude calculation could be replaced with 
% something mode sophisticated:
earthCenter = [0;0;-(Re+alt0)];
hi_km = (sqrt(sum((xyz-earthCenter*ones(1,nPts)).^2))-Re)*0.001; % Altitude (km)(spherical earth)
if any(hi_km <0)
  Latm = Inf; % Below (geometric) horizon
else
  ds_km = nodeDist*0.001/(nPts-1);   % Distance between points (km);
  
  [temperature, pressure, rho] = ITUrefAtmosphere(hi_km, atmosphere.latd, atmosphere.season); 
  gamma = ITUspecificAtten(fghz, temperature, pressure, rho); % dB/km
  
  % Integrate via Simpsons rule (this is why nPts was an odd number):
  hh = ds_km/3;  
  Latm = hh*(gamma(1)+gamma(nPts)) + sum(4*hh*gamma(2:2:nPts-1)) + sum(2*hh*gamma(3:2:nPts-1));
 
end
