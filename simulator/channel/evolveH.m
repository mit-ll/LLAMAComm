function [hOut, hPrime] = evolveH(t, h0, h1)

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

u0 = h0.u;
v0 = h0.v;
g0 = h0.g;
%aL0 = h0.aLeft;
aR0 = h0.aRight;
u1 = h1.u;
v1 = h1.v;
g1 = h1.g;
aL0 = h1.aLeft;
%aR1 = h1.aRight;

gPrime = sqrt(1-t) * g0 + sqrt(t) * g1;

% testing
%g0Eig     = sort(eig(g0*g0'))
%g1Eig     = sort(eig(g1*g1'))
%gPrimeEig = sort(eig(gPrime*gPrime'))

uPrime = u0 * expm(t*logm(u0' * u1));
vPrime = v0 * expm(t*logm(v0' * v1));

hPrime.u      = uPrime;
hPrime.v      = vPrime;
hPrime.g      = gPrime;
hPrime.aLeft  = aL0; % assume both 0 and 1 use same a's
hPrime.aRight = aR0;

hOut          = uPrime * diag(aL0) * gPrime * diag(aR0) * vPrime';
hPrime.h      = hOut;

% test
%frob0 = trace(h0.h*h0.h')
%frob1 = trace(h1.h*h1.h')
%frobP = trace(hOut*hOut')

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


