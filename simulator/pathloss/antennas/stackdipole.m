function GdBi = stackdipole(phi,ff,NN,ll,psi)
% function GdBi = stackdiple(phi,ff,NN,ll,psi)
% get stacked dipole antenna array gain in dBi at elevation angle phi 
% (radians), for signal frequency ff (Hz), with NN dipoles, dipole 
% length ll (m) and added phase delay psi (radians) between dipoles.
% Inter-element spacing is 2*ll (i.e. ll = lambda/2 at design frequency).
% Assumes perfect matching (no antenna loss), i.e., this is
% really directivity. Note that phi is elevation angle, not depression
% angle as usual in antenna literature.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<5 
  psi=0; 
end
lambda  = 3e8/ff;   % wavelength, m
kk = 2*pi./lambda;  % wave number
if nargin<4; ll = lambda/2; end
if nargin<3;
   error('Need at least 3 input arguments, function stackdipole');
end

% check input vector sizes
sms = sizematscalar(phi,ff,NN,ll,psi);
if isnan(sms); 
   error('all matrix arguments must be same size, function stackdipole');
end


% array gain
num   = sin( NN/2.*(psi+kk.*2.*ll.*sin(phi)) );
denom = sin(  1/2.*(psi+kk.*2.*ll.*sin(phi)) );
Ga = zeros(sms);
idx1 = (denom~=0);
Ga(idx1) = db20(abs(num(idx1))) - db20(abs(denom(idx1)));
idx0 = (denom==0);
Ga(idx0) = db20(NN);

% total gain
Ge = dipole(phi,ff,ll);
GdBi = Ga + Ge;





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


