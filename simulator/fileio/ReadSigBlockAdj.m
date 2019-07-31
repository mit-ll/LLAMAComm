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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

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




%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


