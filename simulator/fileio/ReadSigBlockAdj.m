function [sig, sSt, sLen, before, bSt, bLen, after, aSt, aLen] = ...
    ReadSigBlockAdj(filename, fPointer)

% Function sim/ReadSigBlockAdj.m:
% Reads a block of signal data and its adjacent blocks from disk.  
% This function starts reading at the offset specified by fPointer 
% (fPointer must point to the start of a valid signal block).
%
% USAGE: [sig, sSt, sLen, before, bSt, bLen, after, aSt, aLen] = ...
%           ReadSigBlockAdj(filename, fPointer)
%
% Input arguments:
%  filename   (string) Full path and filename to .cog file
%  fPointer   (int) Offset into file.  Must point to the start of a
%              signal block.
%
% Output argument:
%  sig        (MxsLen) Complex samples.  M channels x N samples
%  sSt        (int) Signal block start index
%  sLen       (int) Signal block length
%  before     (MxbLen) Complex samples from the block before
%  bSt        (int) Before block start index
%  bLen       (int) Before block length
%  after      (MxaLen) Complex samples from the block after
%  aSt        (int) After block start index
%  aLen       (int) After block length

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open file for reading
[fid, msg] = fopen(filename, 'r', 'ieee-le');
if fid==-1
  fprintf('ReadSigBlockAdj: Having trouble opening file\n');
  fprintf('"%s" for reading.\n', filename);
  error(msg);
end

% Read main signal block
[sig, fc, fs, count, sSt, sLen] = ReadSigBlock(fid, fPointer); %#ok - fc, fs, count unused

% Find and read signal block before requested block
prevPtr = PrevSigBlock(fid, fPointer);
if prevPtr==-1
  bSt = [];
  bLen = [];
  before = [];
else
  [before, fc, fs, count, bSt, bLen] = ReadSigBlock(fid, prevPtr); %#ok - fc, fs, count unused
end

% Check that before block is really adjacent (wait blocks aren't saved)
if bSt+bLen ~= sSt
  bSt = [];
  bLen = [];
  before = [];
end

% Find and read signal block after requested block
nextPtr = NextSigBlock(fid, fPointer);
if nextPtr==-1
  aSt = [];
  aLen = [];
  after = [];
else
  [after, fc, fs, count, aSt, aLen] = ReadSigBlock(fid, nextPtr); %#ok - fc, fs, count unused
end

% Check that after block is really adjacent (wait blocks aren't saved)
if sSt+sLen ~= aSt
  aSt = [];
  aLen = [];
  after = [];
end

% Close file
fclose(fid);




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


