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


