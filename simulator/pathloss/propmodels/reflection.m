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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check matrix sizes, set default values, etc
if nargin<5; 
  error('not enough intput arguments, function reflection');
end
if ~checkmatscalar(ff, psi, epsr, sigma);
  error('non-scalar arguments must be same size, function reflection');
end
if ~isscalar(pol);
  error('polarization value must be scalar, function reflection');
end

% get reflection coefficient
xx = 18*1e9*sigma./ff; % normalized conductivity (Parsons, p. 20)
if strcmp(pol, 'v') % vertical polarization
  rho = ( (epsr-1j*xx).*sin(psi)-sqrt( epsr-1j*xx-cos(psi).^2 ) ) ./ ...
        ( (epsr-1j*xx).*sin(psi)+sqrt( epsr-1j*xx-cos(psi).^2 ) );
elseif strcmp(pol, 'h');
  rho = ( sin(psi)-sqrt( epsr-1j*xx-cos(psi).^2 ) ) ./ ...
        ( sin(psi)+sqrt( epsr-1j*xx-cos(psi).^2 ) );
else
  error('Unknown polarization value');
end




% Copyright (c) 2006-2012, Massachusetts Institute of Technology All rights
% reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above  copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      * Neither the name of the Massachusetts Institute of Technology nor
%        the names of its contributors may be used to endorse or promote
%        products derived from this software without specific prior written
%        permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


