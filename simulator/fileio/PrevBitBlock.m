function fPtr = PrevBitBlock(fid,fPointer)

% Function fileio/PrevBitBlock.m:
% Returns file offset to previous signal block in the .bit file if it
% exists.
%
% USAGE: fPtr = PrevBitBlock(fid,fPointer)
%
% Input arguments:
%  fid       (file id) Valid file id (see fopen) of a .bit file
%  fPointer  (int) File offset pointing to start of a bit block
%
% Output arguments:
%  fPtr      (int) File offset pointing to previous block.  Returns -1
%             if there are no previous blocks.
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

% Already at start of file
if fPointer==0
    fPtr = -1;
    return;
end

% Find previous block size
if fPointer >= 4
    fseek(fid,fPointer,'bof');
    fseek(fid,-4,'cof');
    blkbytes = fread(fid,1,'uint32');

    fPtr = fPointer-blkbytes;
else
    error('Bad fPointer or bad .bit file.');
end

% Check new pointer
if fPtr < 0
    error('Bad previous block offset!  Bad file or bad fPointer.');
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


