function [env, linkobj] = BuildLink(env, nodeTx, modTx, nodeRx, modRx, nodes)

% Function @env/BuildLink.m:
% Build the link between the module transmitting and the module
% receiving.  This function will call the code of Dan Bliss and
% Bruce McGuffin.
%
% USAGE: [env, linkObj] = BuildLink(env, nodeTx, modTx, nodeRx, modRx)
%
% Input arguments:
%  env      (environment obj) Container for environment parameters
%  nodeTx   (node obj) Node transmitting
%  modTx    (module obj) Module transmitting
%  nodeRx   (node obj) Node receiving
%  modRx    (module obj) Module receiving
%  nodes    (node obj array) Array of node objects
%
% Output argument:
%  env      (environment obj) modifed environment with new link
%  rxsig    (MxN complex) Analog signal received by module.
%            M channels x N samples

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

global chanType
global DisplayLLAMACommWarnings
DEBUGGING = 0;  % Print link at the end

nTx = GetNumAnts(modTx);
nRx = GetNumAnts(modRx);

% Check to see if a reciprocal link exists
%fromID     = {GetNodeName(nodeRx)};
%toID       = {GetNodeName(nodeTx), GetFc(modTx)};
if isempty(env.links)
    reciprocalLink = [];
else
    reciprocalLink = FindReciprocalLink(env.links, nodeTx, modTx, nodeRx, modRx, nodes);
end

%---------------------------------------------
% Generate Channel and Pathloss

% check to see if modTx and modRx are in the same node
if strcmp(GetNodeName(nodeTx), GetNodeName(nodeRx))
  % Co-located modules (self-interference)

  % Generate Parameters
  switch lower(chanType)
    case 'stfcs'
      pathLoss                        = 1;
      channel.chanType                = chanType;
      channel.nDelaySamp              = 1;
      channel.nPropDelaySamp          = 0;
      channel.dopplerSpreadHz         = 0;
      channel.nDopplerSamp            = 1;
      channel.freqOffs                = 0;
      channel.phiOffs                 = 0;
      channel.chanTensor              = zeros(nRx, nTx, 1, 1);
      channel.chanTensor(:, :, :, 1)  = zeros(nRx, nTx);
      propParams.longestCoherBlock    = 1;
      propParams.stfcsChannelOversamp = 3;

    case {'wssus', 'los_awgn', 'env_awgn','wideband_awgn', 'wssus-wideband'}
      pathLoss                     = 1;
      channel.chanType             = chanType;
      channel.longestLag           = 0;
      channel.nPropDelaySamp       = 0;
      channel.riceMatrix           = ones(nRx,nTx);
      propParams                   = [];

  end % END switch on chanType


elseif ~isempty(reciprocalLink)

  % Modules are reciprocal so load the same channel parameters
  reciprocalLink    = struct(reciprocalLink);
  channel           = reciprocalLink.channel;
  pathLoss          = reciprocalLink.pathLoss;
  propParams        = reciprocalLink.propParams;

  if isfield(channel,'chanTensor')
      channel.chanTensor = permute(channel.chanTensor,[2,1,3,4]);
      hUnNorm = permute(channel.chanTensor,[1,2,4,3]);
      channel.chan = hUnNorm(:,:);
  end

   if isfield(channel,'riceMatrix')
       channel.riceMatrix = channel.riceMatrix.';
       channel.powerProfile = channel.powerProfile.';
       channel.chanstates = channel.chanstates.';
   end

else
  % Modules are located in different nodes

  % Extract pertinent environment parameters
  %envParams.scenarioType = env.envType;
  %envParams.building.roofHeight = env.building.avgRoofHeight;
  %envParams.shadow = env.shadow;
  %envParams.los_dist = env.propParams.los_dist;
  %envParams.atmosphere = env.atmosphere;

  envParams = struct(env);

  % Generate Pathloss
  switch lower(chanType)
    case {'los_awgn', 'wideband_awgn'}
      % Line of sight pathloss
      %pathLoss.totalPathLoss = Line_of_sight_loss(nodeTx, modTx, nodeRx, modRx);
      losLoss = Line_of_sight_loss(nodeTx, modTx, nodeRx, modRx);
      temp = GetPathlossStruct(nodeTx, modTx, nodeRx, modRx, envParams);
      antGain = (temp.antGainTx + temp.antGainRx);
      pathLoss.totalPathLoss = losLoss - antGain;
      pathLoss.shadowCorrLoss     = 0;
      pathLoss.shadowStd          = 0;
      pathLoss.shadowLoss         = 0;
      pathLoss.riceMedKdB         = inf;
      pathLoss.riceKdB            = inf;

    case 'env_awgn'
      % Call Bruce McGuffin's Code
      pathLoss = GetPathlossStruct(nodeTx, modTx, nodeRx, modRx, envParams);
      % Remove effects of shadowing
      pathLoss.totalPathLoss = pathLoss.totalPathLoss - pathLoss.shadowLoss;
      pathLoss.shadowCorrLoss     = 0;
      pathLoss.shadowStd          = 0;
      pathLoss.shadowLoss         = 0;
      pathLoss.riceMedKdB         = inf;
      pathLoss.riceKdB            = inf;

    otherwise
      % Call Bruce McGuffin's Code
      pathLoss = GetPathlossStruct(nodeTx, modTx, nodeRx, modRx, envParams);
  end

  % Compute the various propagation parameters
  propParams = GetPropParamsStruct(nodeTx, modTx, nodeRx, modRx, env, pathLoss);
  propParams.chanType = chanType;

  % check to see if link parameters should be user-specified
  if isfield(propParams, 'linkParamFile')
    if ~isempty(propParams.linkParamFile)
      linkStruct.fromID     = {GetNodeName(nodeTx), GetModuleName(modTx)};
      linkStruct.toID       = {GetNodeName(nodeRx), GetModuleName(modRx), GetFc(modRx)};
      linkStruct.pathLoss   = pathLoss;
      linkStruct.propParams = propParams;
      linkStruct            = ParseLinkParamFile(linkStruct);
      pathLoss              = linkStruct.pathLoss;
      propParams            = linkStruct.propParams;
    end
  end


  % Generate Space-Time-Frequency Channel
  nTx = struct(nodeTx);
  mTx = struct(modTx);
  nRx = struct(nodeRx);
  mRx = struct(modRx);
  switch lower(chanType)
    case 'stfcs'
      channel = GetStfcsChannel(nTx, mTx, nRx, mRx, ...
                                propParams, pathLoss);
    case 'wideband_awgn'
      channel = GetGeometricChannel(nTx, mTx, nRx, mRx, ...
           propParams, pathLoss);

    case {'wssus', 'los_awgn', 'env_awgn'}
      channel = GetWssusChannel(nTx, mTx, nRx, mRx, ...
                                propParams, pathLoss);
    case 'wssus-wideband'
      channel = GetWssusWBChannel(nTx, mTx, nRx, mRx, ...
                                  propParams, pathLoss);

  end
end

%---------------------------------------------
% Load the antialias filter taps from file.  They were designed by
% calling the function '/simulator/tools/DesignAntiAliasFilter.m'.
load antiAliasFilterTaps B

%---------------------------------------------
% Create 'link' object

% Channel information
k.channel = channel;
k.pathLoss = pathLoss;
k.chanTail = [];
k.propParams = propParams;

% Inband filter information
k.filterTaps = [];

% Anti-alias filter
k.antialiasTaps = B;

% Link ID's
k.fromID = {GetNodeName(nodeTx), GetModuleName(modTx)};  % {nodeName, moduleName}
k.toID = {GetNodeName(nodeRx), GetModuleName(modRx), GetFc(modRx)};    % {nodeName, moduleName, fc}

linkobj = link(k);


linkID = sprintf('''%s:%s'' -> ''%s:%s:%.2f MHz''', ...
                 k.fromID{1}, k.fromID{2}, ...
                 k.toID{1}, k.toID{2}, k.toID{3}/1e6);
if propParams.txHighFlag
    %warning('In %s, the node named %s is above height threshold set by global variable heightLimitDiffuseScattering.\n Doppler-offset will be added instead of Doppler-spread', linkID, GetNodeName(nodeTx));
    if DisplayLLAMACommWarnings
        fprintf('\nWarning: In %s, the node named %s is above height threshold set by global variable heightLimitDiffuseScattering.\n', linkID, GetNodeName(nodeTx));
        fprintf('           Doppler shift will be added instead of Doppler spread\n');
    end
end

if propParams.rxHighFlag
    %warning('In %s, the node named %s is above height threshold set by global variable heightLimitDiffuseScattering.\n Doppler-offset will be added instead of Doppler-spread', linkID, GetNodeName(nodeRx));
    if DisplayLLAMACommWarnings
        fprintf('\nWarning: In %s, the node named %s is above height threshold set by global variable heightLimitDiffuseScattering.\n', linkID, GetNodeName(nodeRx));
        fprintf('           Doppler shift will be added instead of Doppler spread\n');
    end
end


% Populate the link array of the environment object
env.links = [env.links, linkobj];

if DEBUGGING
  1; %#ok if this line is unreachable
  % Print link to command line
  linkobj
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
