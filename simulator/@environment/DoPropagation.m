function [env,rxsig,outStruct] = DoPropagation(env,nodeTx,modTx,nodeRx,modRx,histIdx,nodes)

% Function @environment/DoPropagation.m:
% Wrapper function that builds links and does the signal
% processing on the transmitted signal.
%
% USAGE: [env,rxsig] = DoPropagation(env,nodeTx,modTx,nodeRx,modRx,histIdx)
%
% Input arguments:
%  env       (environment obj) Container for environment parameters
%  nodeTx    (node obj) Node transmitting
%  modTx     (module obj) Module transmitting
%  nodeRx    (node obj) Node receiving
%  modRx     (module obj) Module receiving
%  histidx   (int) Module history index of relevant transmitted block.
%  nodes     (node obj array) node object array
%
% Output argument:
%  env      (environment obj) modifed environment object
%  rxsig    (MxN complex) Analog signal received by module.  
%            M channels x N samples
%  outStruct (struct) structure containing miscellaneous outputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%---------------------------------------------------------------
% Get the link
fromID = {GetNodeName(nodeTx), GetModuleName(modTx)} ;
toID = {GetNodeName(nodeRx), GetModuleName(modRx), GetFc(modRx)} ;
[linkobj,linkIndex] = FindLink(env,fromID,toID) ;
% build the link if necessary and concatenate it to the link cell array
if isempty(linkobj)
    [env,linkobj] = BuildLink(env,nodeTx,modTx,nodeRx,modRx,nodes) ;
    newLinkFlag = 1;
else
    newLinkFlag = 0;
end

%---------------------------------------------------------------
% Channel Propagation between module objects
[linkobj,rxsig] = PropagateToReceiver(linkobj, modTx, modRx, histIdx) ;



%---------------------------------------------------------------
% Update the link object
if newLinkFlag
    env.links(end) = linkobj ;
else
    env.links(linkIndex) = linkobj ;
end


%---------------------------------------------------------------
% Check if channel impulse response is requested for the block
p = GetUserParams(nodeRx);
if isfield(p,'getChannelResponse') && p.getChannelResponse
    
    % get the receiver module request
    req = GetRequest(modRx);

    % Get starting sample and blockLength of receive block
    startRx = req.blockStart;
    blockLengthRx = req.blockLength;
    
    % Get the channel impulse response and link information
    if isfield(p,'channelResponseTimes') && ~isempty(p.channelResponseTimes)
        if any(p.channelResponseTimes < 0 | p.channelResponseTimes > 1)
            error('Channel response fractional times must be greater than 0 and less than 1!')
        end
        startSamps = round(p.channelResponseTimes*blockLengthRx) + startRx;
    else
        startSamps = round(blockLengthRx/2) + startRx;
    end
    %keyboard
    [outStruct.response,outStruct.linkInfo] = GetChannelResponse(linkobj,startSamps);
else
    outStruct = [];
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


