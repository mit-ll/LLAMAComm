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

global heightLimitDiffuseScattering;

envParams = struct(env);
velocitySpread = envParams.propParams.velocitySpread;
velocityShift = 0;
rangeVector = [];
if(isempty(heightLimitDiffuseScattering))
    heightThresh = 200;
else
    heightThresh = heightLimitDiffuseScattering;
end
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

