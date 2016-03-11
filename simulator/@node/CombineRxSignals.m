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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


