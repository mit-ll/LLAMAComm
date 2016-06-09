function fPtr = NextBitBlock(fid,fPointer)

% Function fileio/NextBitBlock.m:
% Returns file offset to next signal block in the .bit file if it
% exists.
%
% USAGE: fPtr = NextBitBlock(fid,fPointer)
%
% Input arguments:
%  fid       (file id) Valid file id (see fopen) of a .bit file
%  fPointer  (int) File offset pointing to start of a bit block
%
% Output arguments:
%  fPtr      (int) File offset pointing to next block.  Returns -1
%             if there are no more blocks.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


