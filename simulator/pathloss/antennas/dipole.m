function GdBi = dipole(phi, ff, ll)
% function GdB = dipole(phi, ff, ll)
% get dipole antenna gain in dBi at elevation angle phi (radians), for
% signal frequency ff (Hz), and dipole length ll (m).
% Assumes perfect matching - i.e., no antenna loss, i.e. this is
% really directivity. Note that phi is elevation angle, not depression
% angle as usual in antenna literature.
% from Constantine A. Balanis, Antenna Theory, Analysis and Design, 
% Second Edition, Wiley, NY, 1997, eqs. 4-64 and 4-68.

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

% check input vector sizes
[phi, ff, ll] = matsize(phi, ff, ll);
if isnan(phi)
  error('All non-scalar arguments must have same dimension, function dipole');
end

C = 0.5772156649;        % Euler's constant
kk = 2*pi*ff/3e8;  % wave number

% Turn off warning about log of zero
wstate = warning;
warning('off', 'MATLAB:log:logOfZero')

% normalized total transmitter power 
cimat = mycosint( kk.*ll );
Q = C + log(kk.*ll) - cimat + ...
    0.5*sin(kk.*ll) .* ( mysinint(2*kk.*ll) - 2*mysinint(kk.*ll) ) + ...
    0.5*cos(kk.*ll) .* ( C + log(0.5*kk.*ll) + mycosint(2*kk.*ll) - 2*cimat );

% somewhat normalized gain square-root
FF = zeros(size(ff));
idx0 = find(abs(phi-pi/2)>10*eps); % index non-zero-style elevations
FF(idx0) = ( cos( kk(idx0).*ll(idx0)/2 .* sin(phi(idx0)) ) - ...
             cos( kk(idx0).*ll(idx0)/2 ) ) ./ cos(phi(idx0));

% in dBi
GdBi = - nan*ones(size(ff)); % zero gain
GdBi(idx0) = db10(2) + db20( abs(FF(idx0)) ) - db10(Q(idx0)); % Balanis eq. 4-75

% Restore warning messages
warning(wstate);

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


