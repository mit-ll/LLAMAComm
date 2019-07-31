function [out, len] = ReadContiguousData(modobj, reqStart, reqLen, fr)

% Function @module/ReadContiguousData.m:
% Reads saved analog data from a module's associated save file in
% one contiguous block.
%
% It's possible that all the data requested won't be available.
% If data at the beginning is missing, it will be padded with zeros.
% This will only happen in case samples before time zero are requested.
% If data at the end is missing, this function will return as much of the
% requested data as possible.  It will be important to check the start
% index and length of the block that is actually returned.
%
% If no data is avaialable, this function will return out=[] and len=0.
% If data are all wait blocks, this function will return out=[], len=reqLen
%
% USAGE: [out, len] = ReadContiguousData(modobj, reqStart, reqLen)
%
% Input arguments:
%  modobj    (module obj) Module object containing history structure
%  reqStart  (int) Sample index for start of requested block
%  reqLen    (int) Requested block length, L
%  fr        (double) (Hz) Receiver center frequency
%  fs        (double) (Hz) Simulation sample rate
%
% Output arguments:
%  out       (CxLa) Complex data read from file.  This function will
%             return as much data as is available.
%  len       (int) Length of the returned data block
%

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

fs = GetFs(modobj);       % Sampling frequency of the simulation

% Keep track of special case.  If all blocks are wait blocks, return
% out=[], len=reqLen
allWait = 1;

% Initialize output matrix
out = zeros(GetNumAnts(modobj), reqLen);

% Calculate requested stop index
reqEnd = reqStart + reqLen - 1;

% Search history starting from the end
searchIdx0 = 1;
for searchIdx = length(modobj.history):-1:1
  block = modobj.history{searchIdx};
  blockEnd = block.start+block.blockLength-1;

  % Stop when blocks are found before the request
  if blockEnd < reqStart
    searchIdx0 = 1 + searchIdx;
    break;
  end
end

% Search history starting from beginning of the relevant portion
lastIdx = [];
for searchIdx = searchIdx0:length(modobj.history)

  block = modobj.history{searchIdx};
  blockStart = block.start;
  blockEnd = block.start+block.blockLength-1;

  % Skip blocks that are before the start of the request
  if blockEnd<reqStart
    continue;
  end

  % reqLen = reqEnd-reqStart+1;
  blockLen = block.blockLength;
  ft = block.fc;       % Transmiter center frequency

  % Fill with zeros if 'wait' block or out of band else read the data
  if strcmp(block.job, 'wait') || abs(ft - fr) > fs
    sig = zeros(GetNumAnts(modobj), blockLen);
  else
    % Open file for reading, if not already open
    if isempty(modobj.fid)
      [fid, msg] = fopen(modobj.filename, 'r', 'ieee-le');
      if fid==-1
        fprintf('ReadContiguousData: Having trouble opening file\n');
        fprintf('"%s" for reading.\n', modobj.filename);
        error(msg);
      end
    else
      fid = modobj.fid;
    end

    % Read signal block from file
    sig = ReadSigBlock(fid, block.fPtr);

    % Turn off all wait flag since we've found one non-wait block
    allWait = 0;
  end

  % Add relevant blocks to the output matrix
  if blockStart<reqStart && blockEnd>=reqStart && blockEnd<=reqEnd
    % Block overlaps left edge of request
    overlapLen = blockEnd-reqStart+1;
    out(:, 1:overlapLen) = sig(:, end-overlapLen+1:end);
    lastIdx = overlapLen;

  elseif blockEnd>reqEnd && blockStart<=reqEnd && blockStart>=reqStart
    % Block overlaps right edge of request
    overlapLen = reqEnd-blockStart+1;
    out(:, end-overlapLen+1:end) = sig(:, 1:overlapLen);
    lastIdx = reqLen;

  elseif blockStart>=reqStart && blockEnd<=reqEnd
    % Block contained within request
    startOS = blockStart-reqStart+1;
    endOS = startOS+blockLen-1;
    out(:, startOS:endOS) = sig;
    lastIdx = endOS;

  elseif blockStart<reqStart && blockEnd>reqEnd
    % Block spans entire request plus extra on both ends
    startOS = reqStart-blockStart+1;
    endOS = startOS+reqLen-1;
    out = sig(:, startOS:endOS);
    lastIdx = reqLen;

  else
    error('IF statements did not catch all possible cases!');
  end

  % Stop if last requested sample is filled in
  if lastIdx>=reqLen
    len = reqLen;
    break;
  end

end % for searchIdx

% If there was no data available, return out=[], len=0
if isempty(lastIdx)
  out = [];
  len = 0;
  return;
end

% If more samples are needed at the end, but were are available,
% shorten output matrix
if lastIdx<reqLen
  lastBlock = modobj.history{end};
  startOS = lastBlock.start-reqStart+1;
  endOS = startOS+lastBlock.blockLength-1;

  out = out(:, 1:endOS);
  len = endOS;
end

% If all blocks are wait blocks, make out=[]
if allWait == 1
  out = [];
  len = reqLen;
end




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


