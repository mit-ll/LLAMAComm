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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


