function nodeobj = LLMimo_Receive(nodeobj,modname,sig)

% Function user.LL/LLMimo_Receive.m:
% Demodulates the analog input signal and calculates values to pass
% back to the transmitter
%
% USAGE: nodeobj = LLMimo_Receive(nodeobj,modname,sig)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object
%  modname    (string) The name of the module that has activated this
%              callback function
%  sig        (NxblockLen) Analog baseband signal for N channels
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of the node object
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load user parameters
p = GetUserParams(nodeobj);

% Number of receive antennas
nR  = GetNumModAnts(nodeobj,modname);

% Subsample signal
sig = resample(sig.',1,p.nOversamp).';

% Extract noise part of packet
noiseData  = sig(:,1:p.noiseLen);
rNoise     = noiseData*noiseData';
eNoise     = -sort(-dbp(abs(eig(rNoise))));
fprintf('LLMimo Receive Block %d/%d\n',p.receivedBlocks,p.nBlocksToSim);
disp([' rxDemod: eig(rNoise) (dB) = ' num2str(eNoise.')])

% Estimate channel
hTrainData = sig(:,(1:p.hTrainingLen)+p.noiseLen);
hTrainRef  = 1-2*p.hTrainingSeq;
hEst       = inv(sqrtm(rNoise))*hTrainData*hTrainRef'*inv(hTrainRef*hTrainRef');
disp([' rxDemod: frob(hEst)^2 (dB) = ' num2str(abs(trace(hEst*hEst')))]);
eigHEst    = dbp(-sort(-abs(eig(hEst*hEst'))));
disp([' rxDemod: eig(hhd) (dB) =' num2str(eigHEst.')]);

trainData = sig(:,(1:p.trainingLen)+p.noiseLen+p.hTrainingLen);
trainRef  = 1-2*p.trainingSeq;
wTrainData = inv(sqrtm(rNoise))*trainData ;

[u,s,v]         = svd(hEst) ;
vals            = abs(diag(s)) ;
[maxVal, maxIn] = max(vals) ;
vec             = v(:,maxIn) ; %what tx should use...

% Demodulate bits
stTrainData = Stackzs(trainData,p.lagRange) ;
rST         = stTrainData*stTrainData' ;
wUn = inv(rST+p.epsilon*trace(rST)*eye(length(rST))) ...
    *stTrainData*trainRef' ;
w   = wUn / norm(wUn) ;
rxInfoData = sig(:,...
    (1+p.noiseLen + p.trainingLen + p.hTrainingLen):end) ;
rxST = Stackzs(rxInfoData,p.lagRange) ;
y   = w'*rxST ;
y2  = sum(reshape(y,p.spreadRatio,length(y)/p.spreadRatio)) ;

demodBits = y2 < 0 ;

% Save received bits to file for comparison with received bits
[count,fPtr] = WriteBitBlock(p.rxBitsFID,demodBits);

passToTx.vTx = vec/norm(vec) ;
passToTx.domAtten = maxVal^2 ;

disp(' Passed back to Tx:');
disp(['         vTx: ' mat2str(passToTx.vTx,4)]);
disp(['    domAtten: ' num2str(passToTx.domAtten)]);

% Save reverse-link info into user parameters
p.passToTx = passToTx;

% Save user params
nodeobj = SetUserParams(nodeobj,p);


% Temporary helper function
function out=dbp(in)
out = db10(in);


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


