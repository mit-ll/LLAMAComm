function vout = augmentRandNVec(vin,RR,mu)
% function vout = augmentRandNVec(vin,RR,mu);
% given a vector of correlated Gaussian random variables, and a
% correlation matrix and mean for a larger set of random values,
% output an augmented vector that includes all random variables
% vout = [ vnew vin ]', where vnew are the previously unknown rv's.
% The correlation matrix is RR = E{(vout-mu) (vout-mu}'}
% notice that rv's were centered but not normalized before
% computing RR. This is based on results in Monzingo and Miller
% p 531.
% input arguments: vin  (real vector) column vector of known random variables
%                  RR   (real matrix) autocorrelation for all rv's
%                  mu   (real vector) column vector of means for all rv's, default 0
%
% output arguments vout (real vector) column vector all random variables, [ vnew vin ]'
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3; mu = zeros(length(diag(RR)),1); end;

% vector size
Nin  = length(vin);       % number of known values
Nout = length(diag(RR));  % number of values desired
Nnew = Nout-Nin;          % number new values needed
if Nnew==0;
   vout = vin; 
   return; 
elseif Nnew<0
   error('incompatible argument sizes, function augmentRandNVec');
end;

% divide RR into sub-blocks for generating conditional statistics
R11 = RR(1:Nnew,1:Nnew);           % correlation for unknown RV's
R22 = RR(Nnew+1:end,Nnew+1:end);  % correlation for known RV's
R12 = RR(1:Nnew,Nnew+1:end);      % cross correlation


% get mean and variance of unknown RV's, conditioned on known
R22inv = inv(R22);
mucond = mu(1:Nnew) + R12*R22inv*(vin-mu(Nnew+1:end)); %#ok - using inv(R22)
Rcond  = R11 - R12*R22inv*R12'; %#ok - using inv(R22)

% find matrix to transform independent rv's to correlated rv's
[QQ, DD] = eig(Rcond); 
QQ = QQ*sqrtm(DD); % matrix transforms uncorrelated rv's to correlated


% generate correlated rv's
vnew = QQ*randn(Nnew,1) + mucond;
vout = [ vnew; vin ];


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


