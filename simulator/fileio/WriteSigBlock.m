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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


