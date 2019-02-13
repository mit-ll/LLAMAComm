function rho = reflection(ff, psi, epsr, sigma, pol)
% function rho = reflection(ff, epsr, sigma, pol)
% Get reflection coefficient from reflection surface relative dielectric 
% constant, and conductivity, for given frequency and geometry
% All non-scalar input parameters must be the same size
% inputs: ff    = signal frequency, Hz
%         psi   = grazing angle (between surface and wave direction) in rad.
%         epsr  = relative dielectric constant of reflecing surface
%         sigma = conductivity of reflecting surface (Siemens)
%         pol   = polarization ('v'=vertical, 'h'=horizontal), must be scalar
% output: rho   = reflection coefficient

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

% check matrix sizes, set default values, etc
if nargin<5
  error('not enough intput arguments, function reflection');
end
if ~checkmatscalar(ff, psi, epsr, sigma)
  error('non-scalar arguments must be same size, function reflection');
end
if ~isscalar(pol)
  error('polarization value must be scalar, function reflection');
end

% get reflection coefficient
xx = 18*1e9*sigma./ff; % normalized conductivity (Parsons, p. 20)
if strcmp(pol, 'v') % vertical polarization
  rho = ( (epsr-1j*xx).*sin(psi)-sqrt( epsr-1j*xx-cos(psi).^2 ) ) ./ ...
        ( (epsr-1j*xx).*sin(psi)+sqrt( epsr-1j*xx-cos(psi).^2 ) );
elseif strcmp(pol, 'h')
  rho = ( sin(psi)-sqrt( epsr-1j*xx-cos(psi).^2 ) ) ./ ...
        ( sin(psi)+sqrt( epsr-1j*xx-cos(psi).^2 ) );
else
  error('Unknown polarization value');
end




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


