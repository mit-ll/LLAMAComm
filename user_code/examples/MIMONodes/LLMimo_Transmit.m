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


