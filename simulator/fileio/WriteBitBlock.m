function [count,fPtr] = WriteBitBlock(fid,bits)

% Function fileio/WriteBitBlock.m:
% Appends a block of bits to a file opened by InitSaveBits for storing
% binary data.
%
% Data should be binary ones/zeros.  The data will be converted to 
% uint8 before saving.  So it's possible to save values integers in the
% range [0-255] even though this function is intended for saving bits.  
% Data can also be multichannel.  
%
% USAGE: [count,fPtr] = WriteBitBlock(fid,bits)
%
% Input argument:
%  fid   (file id) Valid file id for a file opened by InitSaveBits
%  bits  (MxN int) Bits may take on the values 0 or 1.  M channels by
%         N samples
%
% Output arguments:
%  count (int) Number of bytes written to file
%  fPtr  (int) Offset, in number of bytes, that points to start of block
%         in file.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input variable bits
if length(size(bits))>2
    error('WriteBitBlock: Block saved to file can be 2-dimensional at most.');
end
    
% Number of channels and samples
[nChannels,nSamps] = size(bits);

% Total number of bits (nChannels x nSamples)
nData = nChannels*nSamps;

% Total block size in bytes (16 bytes for header+footer)
nBytes = nData+16;

% Go to end of file
fseek(fid,0,'eof');
startPos = ftell(fid);

% Write header
cnt = fwrite(fid,nBytes,'uint32');
if cnt==0
    disp('File does not seem to be writable.  Was this file opened');
    disp('for writing using InitSaveBits?');
    error('Cannot write to file.');
end
fwrite(fid,nSamps,'uint32');
fwrite(fid,nChannels,'uint32');

% Write data
fwrite(fid,uint8(bits),'uint8');

% Write footer
fwrite(fid,nBytes,'uint32');

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


