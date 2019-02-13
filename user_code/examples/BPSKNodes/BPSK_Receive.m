function nodeobj = BPSK_Receive(nodeobj,modname,sig)

% Function BPSK_Receive.m:
% This is an example of a user-written callback function for a 
% receive module.  This example demodulates an analog, BPSK signal.
%
% This example is designed to work with BPSK_Transmit
%
% USAGE: nodeobj = BPSK_Receive(nodeobj,modname,sig)
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
% See also: BPSK_Transmit.m

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

% Load user parameters
p = GetUserParams(nodeobj);

% Downsample
sig = sig(1:p.nOversamp:end);

% Demod
nSamps = length(sig);
nTrain = p.trainingLen;
sTrain = -(p.trainingSeq*2- 1);

% adapt equalizer
eqLen = p.equalizerLen;
eqDelay = p.equalizerDelay;
R = toeplitz([sig(1) zeros(1,eqLen-1)], sig(1:nTrain));
Sd = [zeros(1,eqDelay),sTrain(1:nTrain-eqDelay)];
f = Sd*R'*inv(R*R');

% equalize and extract bit estimates 
nBits = p.bitLen;
sHat = conv(sig,f);
bits = real(sHat(eqDelay+1:nBits+eqDelay))<0;

% Save rx bits
p.receivedBlocks = p.receivedBlocks+1;
p.rxBits(p.receivedBlocks,:) = bits;

% Save user params
nodeobj = SetUserParams(nodeobj,p);


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


