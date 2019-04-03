function fPtr = NextSigBlock(fid,fPointer)

% Function fileio/NextSigBlock.m:
% Returns file offset to next signal block in the .sig file if it
% exists.
%
% USAGE: fPtr = NextSigBlock(fid,fPointer)
%
% Input arguments:
%  fid       (file id) Valid file id (see fopen) of a .sig file
%  fPointer  (int) File offset pointing to start of a signal block
%
% Output arguments:
%  fPtr      (int) File offset pointing to next block.  Returns -1
%             if there are no more blocks.
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

% Check file size
fseek(fid,0,'eof');
fileend = ftell(fid);

% Already at end of file
if fPointer==fileend
    fPtr = -1;
    return;
end

% Find next block start
fseek(fid,fPointer,'bof');
blkbytes = fread(fid,1,'uint32');
fPtr = fPointer+blkbytes;

% Check next block offset
if fPtr == fileend
    % No next block, end of file reached.
    fPtr = -1;
elseif fPtr > fileend
    % Past end of file.  Oops.
    error('Bad next block offset!  Bad file or bad fPointer.');
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


