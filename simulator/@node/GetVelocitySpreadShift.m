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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

envParams = struct(env);
velocitySpread = envParams.propParams.velocitySpread;
velocityShift = 0;
rangeVector = [];
heightThresh = 200; % This is the height threshold (in meters) for the 
                    % Okumura-Hata Model used in LLAMAComm getPathloss() 
                    % function; we use this as the height threshold above 
                    % which diffuse scattering is assumed to be negligible

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


