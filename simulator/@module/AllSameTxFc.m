function [result, ftout] = AllSameTxFc(modobj, reqStart, reqLen, fr)

% Function @module/AllSameTxFc.m:
% Checks if all the frequency- and time-overlapping transmit blocks 
% have the same center frequency.
%
% If no data is avaialable, this function will return result=1.
% If data are all wait blocks, this function will return result=0.
%
% USAGE: [result, ftout] = AllSameTxFc(modobj, reqStart, reqLen, fr)
%
% Input arguments:
%  modobj    (module obj) Module object containing history structure
%  reqStart  (int) Sample index for start of requested block
%  reqLen    (int) Requested block length, L
%  fr        (double) Receiver center frequency
%
% Output arguments:
%  result    (boolean) 1 if all relevant transmit blocks have the same 
%                      fc, 0 otherwise.
%  ftout     If result is 1, the center frequency of relevant transmit 
%            blocks. Empty otherwise.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Keep track of special case.  If all blocks are wait blocks, return
% out=1
allWait = 1;

% Get the sample rate
fs = GetFs(modobj);

% Calculate requested stop index
reqEnd = reqStart+reqLen-1;

% Search history starting from the end

nHist = length(modobj.history);
pos = 1+nHist;
fcArray = zeros(1, nHist);
for searchIdx = nHist:-1:1
  
  block = modobj.history{searchIdx};
  blockStart = block.start;
  
  % Skip blocks that are after the end of the request
  if blockStart > reqEnd
    continue;
  end

  %blockEnd = block.start+block.blockLength-1;
  ft = block.fc;       % Transmiter center frequency  

  % Fill with zeros if 'wait' block or out of band else process the data
  if strcmp(block.job, 'wait') || abs(ft - fr) > fs
    % Do nothing
  else
    % Add fc to the array
    pos = pos - 1;
    fcArray(pos) = ft;
    
    % Turn off all wait flag since we've found one non-wait block
    allWait = 0;
  end

  % Stop Condition
  if blockStart <= reqStart
    break;
  end
end % for searchIdx
fcArray = fcArray(pos:nHist);

ftout = [];
if allWait == 1  % If all blocks are wait blocks or out of band, make result=[]
  result = [];
else  
  % Else check for changing transmit center frequency
  % Note fcArray is guaranteed to have atleast 1 element
  if all(fcArray == fcArray(1))
    result = 1;
    ftout = fcArray(1);
  else
    result = 0;
  end
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


