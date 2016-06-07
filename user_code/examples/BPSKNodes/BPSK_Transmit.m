function [nodeobj,sig] = BPSK_Transmit(nodeobj,modname,blockLen)

% Function BPSK_Transmit.m:
% This is an example of a user-written callback function for a module
% object.  It generates or loads data to transmit. The output signal 
% should be analog baseband, and can be multichannel.
%
% This example is a single-channel BPSK transmitter.  2x oversampled.
% There is no filtering or pulse shaping, so the signal is full bandwidth.
%
% USAGE: [nodeobj,sig] = BPSK_Transmit(nodeobj,modname,blockLen)
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
% See also: BPSK_Receive.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load user parameters
p = GetUserParams(nodeobj);

% Make some random data and attach training sequence
randdata = rand(1,p.dataLen)>.5;
bits = [p.trainingSeq randdata];
sig = -(bits*2-1);

% Upsample by duplicating bits
sig = repmat(sig,p.nOversamp,1);
sig = sig(:).';

% Calculate signal power (Watts)
filePow = var(sig);

% Set the transmitted signal power
sig = sqrt(p.power/(filePow))*sig;

% Check blockLen
if size(sig,2) ~= blockLen
    error('Block length of Tx data is wrong.');
end



% Save txbits
p.transmittedBlocks = p.transmittedBlocks+1;
p.txBits(p.transmittedBlocks,:) = bits;

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


