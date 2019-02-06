function channel = GetStfcsChannel(nodeTx,modTx,nodeRx,modRx,...
                                   propParams,pathLoss)

% Function 'simulator/channel/GetStfcsChannel.m':  
% Builds channel struct which contains relevant parameters relating 
% to the MIMO link.  This is the interface to Dan Bliss's code.
%
% USAGE:  channel = GetStfcsChannel(nodeTx,modTx,nodeRx,modRx,propParams,pathLoss)
%
% Input arguments:
%  nodeTx           (struct) Node transmitting
%  modTx            (struct) Module transmitting
%  nodeRx           (struct) Node receiving
%  modRx            (struct) Module receiving
%  propParams       (struct) Structure containing Propagation parameters
%  pathLoss         (struct) Structure containing path loss parameters
%
% Output argument:
%  channel          (struct) Structure containing channel parameters
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global includePropagationDelay
global includeFractionalDelay

% Build transmitter node struct
txnode.location = nodeTx.location;
txnode.antLocation = modTx.antPosition;
txnode.fc = modTx.fc;

% Build receiver node struct
rxnode.location = nodeRx.location;
rxnode.antLocation = modRx.antPosition;
rxnode.fc = modRx.fc;

% Extract relavent path loss parameters
totalPathLoss = pathLoss.totalPathLoss;
riceKdB       = pathLoss.riceKdB;

% Get the simulation sample rate
fs = modRx.fs;

overSamp = propParams.stfcsChannelOversamp;

% Extract number of antennas for link
nT   = size(txnode.antLocation,1);
nR   = size(rxnode.antLocation,1);

%tMax = propParams.longestCoherBlock;

c         = 2.998e8; % speed of light
dopSpread = propParams.velocitySpread/c* rxnode.fc; % (Hz)

if includePropagationDelay
  % Determine the propagation delay (number of samples)
  nPropDelaySamp = norm(rxnode.location - txnode.location)/c*fs;
  
  if includeFractionalDelay
    nPropDelaySampFix = fix(nPropDelaySamp);  % Integer part of delay
    d = nPropDelaySamp - nPropDelaySampFix;   % Decimal part of delay
    if d < eps
      % Do rounding because fractional delay is close to zero
      nPropDelaySamp = round(nPropDelaySamp);
    elseif d < 1 - eps
      % Design fractional-delay filter
      nDelayFiltLen = 63;
      t = -(nDelayFiltLen-1)/2:(nDelayFiltLen-1)/2;
      fracDelayFilter = sin(pi*(t-d))./(pi*(t-d));            
    else
      % Do rounding because fractional delay is close to unity
      nPropDelaySamp = round(nPropDelaySamp);
    end
  else % Remove fractional part of delay
    nPropDelaySamp = round(nPropDelaySamp);
  end
  
else
  nPropDelaySamp = 0;  % Assume no propagation delays
end

% Calculate channel tensor from transmit node to receive node
try 
  [hUnNorm, nDelaySamp, nDopSamp, hUnNormTensor, fakeHpow] = ...
      stfChanTensor(...
          propParams.alpha, ...
          nR,nT, ...
          propParams.delaySpread, ...
          1/fs, overSamp, ...
          dopSpread, ...
          propParams.longestCoherBlock, overSamp ); %#ok hUnNorm unused
                                                    
  % Place Rice delay in the middle of the delay spread
  riceDelay = round(nDelaySamp/2);
  % Place Rice tap near the middle of the Doppler spread 
  doppSamp = round((nDopSamp + 1)/2);
  % Get the doppler frequency offsets
  if nDopSamp > 1
    freqOffs = (-((nDopSamp-1)/2):((nDopSamp-1)/2) )...
        *2*overSamp*dopSpread/fs/(nDopSamp - 1);
  else
    freqOffs = 0;
  end
  % Get the random Doppler phase offsets
  %phiOffs = zeros(1,nDopSamp);
  phiOffs = 2*pi*rand(1,nDopSamp);
catch ME
  disp('The error occured somewhere in ''stfChanTensor.m''');
  rethrow(ME);
end

% Generate random phase offset
ricePhaseRad = rand*2*pi;

% wavelength
lam = c/rxnode.fc;

% Get phase matrix
phase = zeros(nR,nT); % LOS path phase: LO (common) plus path length
for rxLoop=1:nR % index Rx
                % Receive antenna location
  rxAntLoc = mic2mac(rxnode.location,rxnode.antLocation(rxLoop,:));
  for txLoop=1:nT % index Tx
                  % Transmit antenna location
    txAntLoc = mic2mac(txnode.location,txnode.antLocation(txLoop,:));
    delr = norm(rxAntLoc-txAntLoc); % range between tx and rx antennas
    phase(rxLoop,txLoop) = delr*2*pi/lam; % Phase offset
  end
end

% Rice matrix:
riceMatrix = exp( 1j*(phase + ricePhaseRad) );

% Normalize the Rice matrix appropriately
riceMatrix = sqrt(fakeHpow)/norm(riceMatrix,'fro')*riceMatrix;

% Add specular tap
riceK = undb10(riceKdB); % Rice K-factor (linear)
if isinf(riceK)
    hUnNormTensor(:,:,doppSamp,riceDelay) = riceMatrix;
else    
    hUnNormTensor(:,:,doppSamp,riceDelay) = ...
        sqrt(riceK)*riceMatrix + hUnNormTensor(:,:,doppSamp,riceDelay);
    
    % Normalize by Rice K-factor
    hUnNormTensor = hUnNormTensor/sqrt(riceK + 1);
end
% Re-create hUnNorm
%hUnNorm = [];  %
%for dopIn = 1:nDopSamp
%  for delayIn = 1:nDelaySamp
%    hUnNorm = [hUnNorm hUnNormTensor(:,:,dopIn,delayIn) ] ;
%  end
%end
hUnNorm = permute(hUnNormTensor, [1, 2, 4, 3]);
hUnNorm = hUnNorm(:, :);

% Build the output struct
channel.chan              = undb10(-totalPathLoss/2) * hUnNorm;
channel.chanTensor        = undb10(-totalPathLoss/2) * hUnNormTensor;
channel.fakeHpow          = fakeHpow;
channel.nDelaySamp        = nDelaySamp;
channel.nPropDelaySamp    = nPropDelaySamp;
channel.longestCoherBlock = propParams.longestCoherBlock;
channel.dopplerSpreadHz   = dopSpread; % (Hz)
channel.nDopplerSamp      = nDopSamp;
channel.hOverSamp         = overSamp;
channel.stfcsChannelOversamp   = propParams.stfcsChannelOversamp;
channel.ricePhaseRad      = ricePhaseRad;
channel.freqOffs          = freqOffs;
channel.phiOffs           = phiOffs;
channel.chanType          = propParams.chanType;
if exist('fracDelayFilter','var')
  channel.fracDelayFilter = fracDelayFilter;
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


