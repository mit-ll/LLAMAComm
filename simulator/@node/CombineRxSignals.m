function [nodes, env, sig] = CombineRxSignals(nodes, env, nodeRxIdx, modRxIdx, relevant)

% Function @node/CombineRxSignals.m:
% Combines analog signals from all sources transmitting at the same
% time.  If there are no modules transmitting, i.e., the transmit
% modules are all in the 'wait' state, then additive noise only
% is received.
%
% USAGE: [env, sig, sigSep] = CombineRxSignals(nodes, modobj, relevant)
%
% Input arguments:
%  nodes     (node obj array) Array of all node object in the simulation
%  env       (environment obj) Environment object (contains evironmental
%             parameters and link objects)
%  nodeRxIdx (int) Index of node that is receiving
%  modRxIdx  (int) Index of module (within node) that is receiving
%  modobj    (module obj) Module object receiving
%  relevant  (cell array) Cell array containing indices of modules
%             containing transmit data that needs to be included
%
% Output argument:
%  nodes     (node obj array) Array of all node object in the simulation
%  env       (environment obj) Modified environment object
%  sig       (MxN complex) Analog signal received by module.
%             M channels x N samples

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

% Get receiving module request
%req = GetRequest(nodes(nodeRxIdx).modules(modRxIdx));

% Recover number of receive antennas
%nChannels = GetNumAnts(nodes(nodeRxIdx).modules(modRxIdx));

% Get receiving node and module
nodeRx = nodes(nodeRxIdx);
modRx = nodes(nodeRxIdx).modules(modRxIdx);

% Check if the received signals should be separated
p = GetUserParams(nodeRx);
if isfield(p, 'separateTheReceivedSignals')
  separateTheReceivedSignals = p.separateTheReceivedSignals;
else
  separateTheReceivedSignals = false;
end
if isfield(p, 'getChannelResponse')
  getChannelResponse = p.getChannelResponse;
  chanResp = []; % Initialize the channel response
else
  getChannelResponse = false;
end


% Add white Gaussian noise (includes external noise)
sig = GetAdditiveNoise(env, modRx); % sig = zeros(nChannels, req.blockLength);
if separateTheReceivedSignals
  % Separate the noise
  sigSep.additiveNoise = sig;
end

if ~isempty(relevant)  % If there are in-band transmitters
  for relLoop = 1:length(relevant)

    histIdx = relevant{relLoop}.histidx; % Not currently used
    nodeTxIdx = relevant{relLoop}.nodeidx;
    modTxIdx = relevant{relLoop}.modidx;

    nodeTx = nodes(nodeTxIdx);
    modTx = nodes(nodeTxIdx).modules(modTxIdx);

    % Apply the channel
    [env, rxsig, outStruct] = ...
        DoPropagation(env, ...
                      nodes(nodeTxIdx), nodes(nodeTxIdx).modules(modTxIdx), ...
                      nodes(nodeRxIdx), nodes(nodeRxIdx).modules(modRxIdx), histIdx, nodes);


    % Accumulate total received signal
    if ~isempty(rxsig)
      sig = sig + rxsig;
      if separateTheReceivedSignals
        % Build a structure of separated received signals
        sigSep.(GetNodeName(nodeTx)).(GetModuleName(modTx)) = rxsig;
      end
      if getChannelResponse
        % Collect the channel impulse responses and information
        chanResp.(GetNodeName(nodeTx)).(GetModuleName(modTx)).response...
            = outStruct.response;
        chanResp.(GetNodeName(nodeTx)).(GetModuleName(modTx)).linkInfo...
            = outStruct.linkInfo;
      end
    end

  end
end

if separateTheReceivedSignals
  % Update the user Parameters with the separated signals
  nodes(nodeRxIdx).user.sigSep = sigSep;
end
if getChannelResponse
  % Update the user Parameters with the channel responses
  nodes(nodeRxIdx).user.chanResp = chanResp;
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


