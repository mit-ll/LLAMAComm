function GdBi = stackdipole(phi,ff,NN,ll,psi)
% function GdBi = stackdiple(phi,ff,NN,ll,psi)
% get stacked dipole antenna array gain in dBi at elevation angle phi 
% (radians), for signal frequency ff (Hz), with NN dipoles, dipole 
% length ll (m) and added phase delay psi (radians) between dipoles.
% Inter-element spacing is 2*ll (i.e. ll = lambda/2 at design frequency).
% Assumes perfect matching (no antenna loss), i.e., this is
% really directivity. Note that phi is elevation angle, not depression
% angle as usual in antenna literature.

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

if nargin<5 
  psi=0; 
end
lambda  = 3e8/ff;   % wavelength, m
kk = 2*pi./lambda;  % wave number
if nargin<4
    ll = lambda/2; 
end
if nargin<3
   error('Need at least 3 input arguments, function stackdipole');
end

% check input vector sizes
sms = sizematscalar(phi,ff,NN,ll,psi);
if isnan(sms)
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


