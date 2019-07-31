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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

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


%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


