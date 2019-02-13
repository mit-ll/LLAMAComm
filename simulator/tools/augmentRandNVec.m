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

if nargin<3; mu = zeros(length(diag(RR)),1); end

% vector size
Nin  = length(vin);       % number of known values
Nout = length(diag(RR));  % number of values desired
Nnew = Nout-Nin;          % number new values needed
if Nnew==0
   vout = vin; 
   return; 
elseif Nnew<0
   error('incompatible argument sizes, function augmentRandNVec');
end

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


