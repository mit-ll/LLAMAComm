function propParams = GetPropParamsStruct(nodTx,modTx,nodRx,modRx,env,pathLoss)

% Function '@node/GetPropParamsStruct.m':  
% Builds propParams struct which contains relevant link parameters.
%
% USAGE:  propParams = GetPropParamsStruct(nodeTx,modTx,nodeRx,modRx,env)
%
% Input arguments:
%  nodTx            (node obj) Node transmitting
%  modTx            (module obj) Module transmitting
%  nodRx            (node obj) Node receiving
%  modRx            (module obj) Module receiving
%  env              (environment obj) Environment object
%  pathLoss         (struct) Output of @node/GetPathlossStruct.m
%
% Output argument:
%  propParams   (struct) Propagation parameters for link
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

global randomDelaySpread

% Get the environment object parameters
envParams = struct(env);

% Extract the propParams
propParams = envParams.propParams;

% build output struct
if randomDelaySpread
    propParams.delaySpread   = GetDelaySpread(nodTx,modTx,nodRx,modRx,...
                                              env,pathLoss);
else
    propParams.delaySpread   = envParams.propParams.delaySpread;
end
%propParams.velocitySpread    = GetVelocitySpread(nodTx,modTx,nodRx,modRx,env);
[propParams.velocitySpread, ...
 propParams.velocityShift, ...
 propParams.txHighFlag, ...
 propParams.rxHighFlag] = GetVelocitySpreadShift(nodTx,modTx,nodRx,modRx,env);
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


