function [bits,nextBlockPtr] = ReadBitBlock(fid,fPointer)

% Function fileio/ReadBitBlock.m:
% Reads a block of bit data from disk.  This function starts reading
% at the offset specified by fPointer (fPointer must point to the start
% of a valid signal block).
%
% This function leaves the file pointer pointing to the start of the
% NEXT block.  Use NextBitBlock and PrevBitBlock to navigate the file,
% or use nextBlockPtr to read sequentially.
%
% Note: NextBitBlock(fid,fPointer) == nextBlockPtr
%
% Returns bits=[], nextBlockPtr=-1 if at end of file.
%
% USAGE: [bits,nextBlockPtr] = ReadBitBlock(fid,fPointer)
%
% Input arguments:
%  fid           (fid) File Identifier for valid .bit file (see fopen)
%  fPointer      (int) Offset into file.  Must point to the start of a
%                 bit block.
%
% Output argument:
%  bits          (MxN) uint8 data.  M channels x N samples
%  nextBlockPtr  (int) Pointer to start of next block
%
% See also: NextBitBlock.m, PrevBitBlock.m
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find end of file
fseek(fid,0,'eof');
eofPos = ftell(fid);

% Move file pointer to start of block
fseek(fid,fPointer,'bof');
startPos = ftell(fid);

% Check for end of file
if startPos==eofPos
    bits = [];
    nextBlockPtr = -1;
    return;
end

% Read in header
nBytesHeader = fread(fid,1,'uint32');
nSamps = fread(fid,1,'uint32');
nChannels = fread(fid,1,'uint32');

% Read samples
bits = fread(fid,[nChannels nSamps],'uint8');

% Read footer
nBytesFooter = fread(fid,1,'uint32');

% Return pointer to start of next block
nextBlockPtr = ftell(fid);

% Calculate total size in bytes
stopPos = nextBlockPtr-1;
count = stopPos-startPos+1;

% Quick checks for possible errors
if count~=nBytesHeader || count~=nBytesFooter
    error('Byte count mismatch.');
end
if nChannels~=size(bits,1) || nSamps~=size(bits,2)
    error('Wrong number of samples.');
end







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


