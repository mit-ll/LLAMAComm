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


