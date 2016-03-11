function [hOut, hPrime] = evolveH(t, h0, h1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


