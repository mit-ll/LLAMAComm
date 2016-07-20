function Latm = atmosphericLoss_nofrec(fghz, tx_xyz, rx_xyz, atmosphere)

if nargin < 4
  atmosphere = struct('latd',[], 'season', []);
end

% Airborne parameters   
hg = 0; % Ground height, in meters
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
earthCenter = [0;0;-Re];
hi_km = (sqrt(sum((xyz-earthCenter*ones(1,nPts)).^2))-Re)*0.001; % Altitude (km)(spherical earth)
if any(hi_km <0)
  Ldb = Inf; % Below (geometric) horizon
else
  ds_km = nodeDist*0.001/(nPts-1);   % Distance between points (km);
  
  [temperature, pressure, rho] = ITUrefAtmosphere(hi_km, atmosphere.latd, atmosphere.season); 
  gamma = ITUspecificAtten(fghz, temperature, pressure, rho); % dB/km
  
  % Integrate via Simpsons rule (this is why nPts was an odd number):
  hh = ds_km/3;  
  Latm = hh*(gamma(1)+gamma(nPts)) + sum(4*hh*gamma(2:2:nPts-1)) + sum(2*hh*gamma(3:2:nPts-1));
 
end
