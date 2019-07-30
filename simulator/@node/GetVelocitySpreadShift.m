function [velocitySpread, velocityShift, txHighFlag, rxHighFlag] = GetVelocitySpreadShift(nodTx, modTx, nodRx, modRx, env); %#ok

% Function '@node/GetVelocitySpreadShift.m':  
% Computes the velocity spread and shift given the node and environment parameters.
%
% USAGE:  velocitySpread = GetVelocitySpread(nodeTx, modTx, nodeRx, modRx, env)
%
% Input arguments:
%  nodeTx           (node obj) Node transmitting
%  modTx            (module obj) Module transmitting
%  nodeRx           (node obj) Node receiving
%  modRx            (module obj) Module receiving
%  env              (environment obj) Environment object
%
% Output argument:
%  velocitySpread   (double) (m/s) Velocity spread in the link
%  velocityShift    (double) (m/s) Velocity shift in the link
%  txHighFlag       (boolean) Flag indicating that the TX node is above the
%                    height threshold for Doppler spread (a shift will be 
%                    applied instead)
%  rxHighFlag       (boolean) Flag indicating that the RX node is above the
%                    height threshold for Doppler spread (a shift will be
%                    applied instead)

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

global heightLimitDiffuseScattering;

envParams = struct(env);
velocitySpread = envParams.propParams.velocitySpread;
velocityShift = 0;
rangeVector = [];
heightThresh = heightLimitDiffuseScattering; 

% Transmitter spread vs. shift decision
txHeight = nodTx.location(3);
if(txHeight > heightThresh) 
    txHighFlag = true;
    rangeVector = nodRx.location - nodTx.location;
    doppVelTx = dot(nodTx.velocity, rangeVector) ./ norm(rangeVector);
    velocityShift = velocityShift + doppVelTx;
else
    txHighFlag = false;
    velocitySpread = velocitySpread + norm(nodTx.velocity);
end

% Receiver spread vs. shift decision
rxHeight = nodRx.location(3);
if(rxHeight > heightThresh)
    rxHighFlag = true;
    if(isempty(rangeVector))
        rangeVector = nodRx.location - nodTx.location;
    end
    doppVelRx = -1*dot(nodRx.velocity, rangeVector) ./ norm(rangeVector);
    velocityShift = velocityShift + doppVelRx;
else
    rxHighFlag = false;
    velocitySpread = velocitySpread + norm(nodRx.velocity);
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

