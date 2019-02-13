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


