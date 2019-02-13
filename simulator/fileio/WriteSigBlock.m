function [count, fPtr] = WriteSigBlock(fid, sig, startIdx, precision, fc, fs)

% Function fileio/WriteSigBlock.m:
% Writes a block of signal data to disk, along with some header
% information.  Running this function puts the file pointer at the end
% of the file.
%
% USAGE: count = WriteSigBlock(fid, sig, startIdx, nSamps, nChannels, ...
%                precision, fc, fs)
%
% Input arguments:
%  fid        (fid) File Identifier (see fopen)
%  sig        (MxN) Complex samples.  M channels x N samples
%  startIdx   (int) Sample index for start of block (simulation samples, 
%              not file samples)
%  precision  (string) 'float32' or 'float64'
%  fc         (double) Center frequency of modulated signal, Hz
%  fs         (double) Sample rate, Hz  (Should be constant)
%
%
% Output argument:
%  count      (int) Number of bytes written to file
%  fPtr       (int) Offset that points to start of block in file
%

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

% Recover number of samples and number of channels
nSamps = size(sig, 2);
nChannels = size(sig, 1);

% Convert precision to #
switch precision
  case 'float32'
    prec = 0;
    BpS = 4;          % Bytes/sample
  case 'float64'
    prec = 1;
    BpS = 8;          % Bytes/sample
  otherwise
    error('Unrecognized precision string ''%s''\n', precision);
end

% Calculate bytes required to store block
nBytesData = 2*nSamps*nChannels*BpS; 
nBytesHeader = 44;
nBytesTot = nBytesData+nBytesHeader;

% Move file pointer to end of file (append data)
fseek(fid, 0, 'eof');
startPos = ftell(fid);

% Write header
fwrite(fid, nBytesTot, 'uint32');
fwrite(fid, startIdx, 'uint32');
fwrite(fid, nSamps, 'uint32');
fwrite(fid, nChannels, 'uint32');
fwrite(fid, prec, 'uint32');
fwrite(fid, BpS, 'uint32');
fwrite(fid, fc, 'float64');
fwrite(fid, fs, 'float64');

% Write samples
sigrow = sig(:).';
fwrite(fid, [real(sigrow); imag(sigrow)], precision);

% Write footer
fwrite(fid, nBytesTot, 'uint32');

% Calculate total size in bytes
stopPos = ftell(fid)-1;
count = stopPos-startPos+1;

% Return file pointer
fPtr = startPos;


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


