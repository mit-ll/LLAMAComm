function [sig, fc, fs, count, startIdx, nSamps] = ReadSigBlock(fid, fPointer)

% Function fileio/ReadSigBlock.m:
% Reads a block of signal data from disk.  This function starts reading
% at the offset specified by fPointer (fPointer must point to the start
% of a valid signal block).
%
% USAGE: [sig, fc, fs, count, startIdx, nSamps] = ReadSigBlock(fid, fPointer)
%
% Input arguments:
%  fid        (fid) File Identifier (see fopen)
%  fPointer   (int) Offset into file.  Must point to the start of a
%              signal block.
%
% Output argument:
%  sig        (MxN) Complex samples.  M channels x N samples
%  fc         (double) Center frequency of modulated signal, Hz
%  fs         (double) Sample rate, Hz  (Should be constant)
%  count      (int) Total bytes read from file
%  startIdx   (int) Start index of block (in # samples)
%  nSamps     (int) Number of samples in block
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Move file pointer to start of block
fseek(fid, fPointer, 'bof');
startPos = ftell(fid);

% Read in header
nBytesTot = fread(fid, 1, 'uint32');
startIdx = fread(fid, 1, 'uint32');
nSamps = fread(fid, 1, 'uint32');
nChannels = fread(fid, 1, 'uint32');
prec = fread(fid, 1, 'uint32');
BpS = fread(fid, 1, 'uint32'); %#ok - BpS unused
fc = fread(fid, 1, 'float64');
fs = fread(fid, 1, 'float64');

% Convert precision to #
switch prec
  case 0
    precision = 'float32';
    BpS = 4; %#ok - BpS (Bytes/sample) unused    
  case 1
    precision = 'float64';
    BpS = 8; %#ok - BpS (Bytes/sample) unused
  otherwise
    error('Unrecognized precision value %d.  Bad block?\n', prec);
end

% Read samples
sig = fread(fid, [nChannels*2 nSamps], precision);
sig = complex(sig(1:2:end, :), sig(2:2:end, :));

% Read footer
nBytesTot2 = fread(fid, 1, 'uint32');

% Calculate total size in bytes
stopPos = ftell(fid)-1;
count = stopPos-startPos+1;

% Quick checks for possible errors
if count~=nBytesTot || count~=nBytesTot2
  error('Byte count mismatch.');
end
if nChannels~=size(sig, 1) || nSamps~=size(sig, 2)
  error('Wrong number of samples.');
end







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


