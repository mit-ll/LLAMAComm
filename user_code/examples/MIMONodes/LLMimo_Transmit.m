function [nodeobj,sig] = LLMimo_Transmit(nodeobj,modname,blockLen)

% Function user.LL/LLMimo_Transmit.m:
% Load data and modulate it for transmission using a simple 
% MIMO scheme.
%
% USAGE: [nodeobj,sig] = LLMimo_Transmit(nodeobj,modname,blockLen)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object
%  modname    (string) The name of the module that has activated this
%              callback function
%  blockLen   (int) The block length of the analog signal expected
%              by the arbitrator
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of the node object
%  sig        (NxblockLen) Analog baseband signal for N channels
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load user parameters
p = GetUserParams(nodeobj);

% Number of transmit antennas
nT  = GetNumModAnts(nodeobj,modname);

% Adjust transmit beamformer and power based on info passed back from
% receiver
if ~isempty(p.getFromRx)
    p.txV = p.getFromRx.vTx; 
    p.txPower = p.txPower/(p.getFromRx.domAtten/p.targDomAtten);
else
    p.txV = ones(nT,1)/sqrt(nT);
    p.txPower = 1;
end

fprintf('LLMimo Transmit Block %d/%d\n',p.transmittedBlocks,p.nBlocksToSim);
disp(['  txPower: ' num2str(p.txPower)]);

% Save transmitted bits to file for comparison with received bits
[count,fPtr] = WriteBitBlock(p.txBitsFID,p.infoBits);

% A really bad code
coded = repmat(p.infoBits,p.spreadRatio,1);
coded = coded(:).';

% BPSK modulation
hTrainModulated = 1-2*p.hTrainingSeq;
modulated = 1-2*[p.trainingSeq coded];

% Build transmitted analog signal
sig = [zeros(nT,p.noiseLen) hTrainModulated p.txV*modulated] ; 

% Resample signal
sig = resample(sig.',p.nOversamp,1).';

% File Power
filePow = 1;  % (Watts) This is variance of 'modulated' (1 ohm load)

% Set the transmitted signal power
sig = sqrt(p.txPower/filePow)*sig;


% Check blockLen
if size(sig,2) ~= p.blockLen
    error('Block length of Tx data is wrong.');
end

% Save user params
nodeobj = SetUserParams(nodeobj,p);


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


