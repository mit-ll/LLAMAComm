function [fromMod, toMod] = GenieTransmit(fromMod, toMod)

% Function @module/GenieTransmit.m:
% Special function that moves data from one genie module's queue to
% another--in effect "transmitting" the data over a genie channel.
%
% USAGE: [fromMod, toMod] = GenieTransmit(fromMod, toMod)
%
% Input arguments:
%  fromMod    (module obj) Special genie module containing data to be
%              transmitted
%  toMod      (module obj) Special genie module that will be receiving
%              data
%
% Output arguments:
%  fromMod    (module obj) Genie module with data removed from the queue.
%  toMod      (module obj) Genie module with data added to queue
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

% Check inputs
if ~IsGenie(fromMod) || ~IsGenie(toMod)
    error('GenieTransmit is only for use with genie modules.');
end
if ~(strcmp(fromMod.type, 'transmitter') && strcmp(toMod.type, 'receiver'))
    error('fromMod must be a transmitter and toMod must be a receiver.');
end

% Move data from fromMod to toMod
toMod.genieQueue = cat(2, toMod.genieQueue, fromMod.genieQueue);

% Deassert transmit request flag and "to" fields

if ischar(fromMod.genieToNodeName)
  fromMod.genieToNodeName = '';
  fromMod.genieToModName = '';
elseif iscell(fromMod.genieToNodeName)
  fromMod.genieToNodeName = fromMod.genieToNodeName(2:end);
  fromMod.genieToModName = fromMod.genieToModName(2:end);
end

if isempty(fromMod.genieToNodeName)
  fromMod.genieQueue = {};
  fromMod.requestFlag = 0;
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


