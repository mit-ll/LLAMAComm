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


