function [result, ftout] = AllSameTxFc(modobj, reqStart, reqLen, fr)

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


