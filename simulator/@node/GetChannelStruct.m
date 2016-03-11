function channel = GetChannelStruct(nodeTx,modTx,nodeRx,modRx,...
                                    propParams,pathLoss)

% Function '@node/GetChannelStruct.m':  
% Builds channel struct which contains relevant parameters relating 
% to the MIMO link.  This is the interface to Dan Bliss's code.
%
% USAGE:  channel = GetChannelStruct(nodeTx,modTx,nodeRx,modRx,propParams)
%
% Input arguments:
%  nodeTx           (node obj) Node transmitting
%  modTx            (module obj) Module transmitting
%  nodeRx           (node obj) Node receiving
%  modRx            (module obj) Module receiving
%  propParams       (struct) Structure containing Propagation parameters
%  pathLoss         (struct) Structure containing path loss parameters
%
% Output argument:
%  channel          (struct) Structure containing channel parameters
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert objects to structs and call /simulator/channel/Get*Channel.m
nodeTx = struct(nodeTx);
modTx  = struct(modTx);
nodeRx = struct(nodeRx);
modRx  = struct(modRx);

switch lower(propParams.chanType)
    case 'sampled'
        channel = GetSampledChannel(nodeTx,modTx,nodeRx,modRx,propParams,...
                                    pathLoss);
    case 'iid'
        channel = GetIidChannel(nodeTx,modTx,nodeRx,modRx,propParams,...
                                pathLoss);
end
channel.chanType = propParams.chanType;

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


