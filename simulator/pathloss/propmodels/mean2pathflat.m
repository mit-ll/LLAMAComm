function L = mean2pathflat(dk, h1, h2, ff, pol, epsr, sigma)
% function L = mean2pathflat(d, h1, h2, f, epsr, sigma)
% local mean path loss due to two-path progagation in flatland
% does not assume antenna heights much less than range, 
% but range must be short enough to ignore earth curvature.
% If dielectric constant and conductivity are not input, rho = -1
% All non-scaler input parameters must be vectors of the same size
% inputs: dk    = range, km
%         h1    = one antenna height, m
%         h2    = other antenna height, m
%         ff    = signal frequency, MHz
%         pol   = polarization ('v'=vertical, 'h'=horizontal), 
%                 default 'v', must be scaler
%         epsr  = relative dielectric constant of reflecing surface
%         sigma = conductivity of reflecting surface (Siemens)
% output: L     = local mean propagation loss (dB)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check matrix sizes, set default values, etc

if nargin<5 || isempty(pol)
  pol = 'v'; 
end
if nargin<4; error('Minimum four input variables'); end
if any(dk<0) || any(h1<0) || any(h2<0);
  warning('mean2pathflat:negativeVars', 'Negative input variables, who knows what will happen');
end
% convert all numerical inputs to equal sized matrices
[ dk h1 h2 ff ] = matsize(dk, h1, h2, ff); 
if any([isnan(dk), isnan(h1), isnan(h2), isnan(ff) ])
  error('All non-scaler input variables must be equal sized');
end
if nargin<7 || isempty(epsr) || isempty(sigma); 
  rhoflag = -1;
else 
  [ epsr sigma ] = matsize(dk, epsr, sigma);
  if any( [ isnan(epsr) isnan(sigma) ]);
    error('All non-scaler input variables must be equal sized');
  end
  rhoflag = 0;
end

dm = 1000*dk;  % range in meters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get propagation loss 
L = zeros(size(dm));

% find exact parameters at range
lambda = 3e2./ff;  % wavelength, m
rm = sqrt( dm.^2 + (h1-h2).^2 ); % slant range, m
delr = sqrt( dm.^2 + (h1+h2).^2 ) - rm; % differential delay, m
delphi = 2*pi*delr./lambda; % differential delay in radians
psi = atan((h1+h2)./dm); % reflection point elevation angle, rad.

% get smaller relative delay-path path-loss without averaging
idxsmall = find(delphi<=pi/2);
if rhoflag==0; 
  rho = reflection(1e6*ff(idxsmall), psi(idxsmall), ...
                   epsr(idxsmall), sigma(idxsmall), pol);
else 
  rho = -1*ones(size(idxsmall));
end
E = 1 + rho.*exp(-1j*delphi(idxsmall)); % normalized signal 

L(idxsmall) = db20(4*pi*rm(idxsmall)./lambda(idxsmall)) - ...
    db20(abs(E)); % loss in dB 

% for larger relative delay-paths, average values
idxbig = find(delphi>pi/2);  
if rhoflag==0; 
  rho = reflection(1e6*ff(idxbig), psi(idxbig), ...
                   epsr(idxbig), sigma(idxbig), pol);
else 
  rho = -1*ones(size(idxbig));
end
Esq = 1 + rho.*conj(rho); % normalized signal 
L(idxbig) = db20(4*pi*rm(idxbig)./lambda(idxbig)) - ...
    db10(Esq); % loss in dB 


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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


