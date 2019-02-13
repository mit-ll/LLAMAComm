function [response, histidx] = CheckHistory(modobj, startidx, stopidx, fc, fs)

% Function @module/CheckHistory.m:
% Examines the history field of a module to see if it contains transmit
% data between the specified startidx and stopidx.  Returns history 
% indices containing the required data.
%
% USAGE: response = CheckHistory(modobj, startidx, stopidx, fc, fs)
%
% Input arguments:
%  modobj    (module obj) Module object
%  startidx  (int) Start index
%  stopidx   (int) Stop index
%  fc        (scalar) Center frequency
%  fs        (scalar) Sampling rate
%
% Output argument:
%  response  (string) One of:
%              'data_available': If transmit data is available
%              'not_transmitting_inband': Module is not a transmitter or 
%                   never transmits in-band during this time
%              'not_ready': Transmit data not available yet
%  histidx   (1xB) Indices for the B blocks containing the relevant
%             data.
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

% Default output
histidx = [];

% Respond with 'not_transmitting' if this is not a transmitter module
if ~strcmp('transmitter', modobj.type)
  response = 'not_transmitting_inband';
  return;
end

% If the requested region is beyond the history of the module, 
% return 'not_ready' unless the module is marked as done.
if isempty(modobj.history) || ...
      modobj.history{end}.start+modobj.history{end}.blockLength-1 < stopidx
  if strcmp('done', modobj.job)
    response = 'not_transmitting_inband';
  else
    response = 'not_ready';
  end
  return;
end

% test if all the overlapping blocks are 'wait' jobs
allWait = 1;

% Search backwards from end of history for blocks containing
% transmit data
nHist = length(modobj.history);
pos = 1+nHist;
histidx = zeros(1, nHist); % Preallocate
for k = nHist:-1:1
  objHist = modobj.history{k};
  blockstart = objHist.start;
  blockend = blockstart+objHist.blockLength-1;

  % Quit if history blocks are prior to block of interest
  if blockend < startidx
    break;
  end
  
  % Check for overlap in time and frequency
  if Overlap(startidx, stopidx, blockstart, blockend) &&...
        (abs(objHist.fc-fc) <= fs) &&...
        (strcmp(objHist.job, 'transmit') ||...
         strcmp(objHist.job, 'wait'))
    pos = pos -1;
    histidx(pos) = k;
    %histidx = [k, histidx];

    if strcmp(objHist.job, 'transmit')
      allWait = 0;
    end
  end
end
histidx = histidx(pos:nHist);

% Return response
if isempty(histidx)
  response = 'not_transmitting_inband';
elseif allWait
  response = 'not_transmitting_inband';
else
  response = 'data_available';
end



%----------------------------------------------------------------------
% Function Overlap:
% Returns true if there is any time overlap between segments A and B

function t = Overlap(A1, A2, B1, B2)

if ((B1>=A1) && (B1<=A2)) || ((A1>=B1) && (A1<=B2))
  t = true;
else
  t = false;
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


