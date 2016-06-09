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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


