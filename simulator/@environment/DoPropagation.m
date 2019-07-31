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


