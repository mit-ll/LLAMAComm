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


