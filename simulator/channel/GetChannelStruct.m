function channel = GetChannelStruct(nodeTx, modTx, nodeRx, modRx, ...
                                    propParams, totalPathLoss, ...
                                    riceKdB)

% Function 'simulator/channel/GetChannelStruct.m':  
% Builds channel struct which contains relevant parameters relating 
% to the MIMO link.  This is the interface to Dan Bliss's code.
%
% USAGE:  channel = GetChannelStruct(nodeTx, modTx, nodeRx, modRx, propParams)
%
% Input arguments:
%  nodeTx           (struct) Node transmitting
%  modTx            (struct) Module transmitting
%  nodeRx           (struct) Node receiving
%  modRx            (struct) Module receiving
%  propParams       (struct) Structure containing Propagation parameters
%  totalPathLoss    (double) (dB) Total pathloss
%
% Output argument:
%  channel          (struct) Structure containing channel parameters
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

% Get the simulation sample rate
fs = modRx.fs;

overSamp = propParams.channelOversamp;

% Extract number of antennas for link
nT   = size(txnode.antLocation, 1);
nR   = size(rxnode.antLocation, 1);

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
      t = (-(nDelayFiltLen-1)/2:(nDelayFiltLen-1)/2);
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
          nR, nT, ...
          propParams.delaySpread, ...
          1/fs, overSamp, ...
          dopSpread, ...
          propParams.longestCoherBlock, overSamp ); %#ok hUnNorm unused
catch ME
  disp('The error occured somewhere in ''stfChanTensor.m''')
  rethrow(ME);
end 

% Generate random phase offset
ricePhaseRad = rand*2*pi;

% wavelength
lam = c/rxnode.fc;

% Get phase matrix
doppSamp = round((nDopSamp + 1)/2);
riceDelay = 1;
phase = zeros(nR, nT); % LOS path phase: LO (common) plus path length
for rxLoop=1:nR % index Rx
                % Receive antenna location
  rxAntLoc = mic2mac(rxnode.location, rxnode.antLocation(rxLoop, :));
  for txLoop=1:nT % index Tx
                  % Transmit antenna location
    txAntLoc = mic2mac(txnode.location, txnode.antLocation(txLoop, :));
    delr = norm(rxAntLoc-txAntLoc); % range between tx and rx antennas
    phase(rxLoop, txLoop) = delr*2*pi/lam; % Phase offset
  end
end

% Rice matrix:
riceMatrix = exp( 1j*(phase + ricePhaseRad) );

% Normalize the Rice matrix appropriately
riceMatrix = sqrt(fakeHpow)/norm(riceMatrix, 'fro')*riceMatrix;

% Add specular tap
riceK = undb10(riceKdB); % Rice K-factor (linear)
if isinf(riceK)
    hUnNormTensor(:, :, doppSamp, riceDelay) = riceMatrix;
else
    hUnNormTensor(:, :, doppSamp, riceDelay) = ...
        sqrt(riceK)*riceMatrix + hUnNormTensor(:, :, doppSamp, riceDelay);
    
    % Normalize by Rice K-factor
    hUnNormTensor = hUnNormTensor/sqrt(riceK + 1);
end
% Re-create hUnNorm
%hUnNorm = [];  %
%for dopIn = 1:nDopSamp
%  for delayIn = 1:nDelaySamp
%    hUnNorm = [hUnNorm hUnNormTensor(:, :, dopIn, delayIn) ] ;
%  end
%end
hUnNorm = permute(hUnNormTensor, [1,2,4,3]);
hUnNorm = hUnNorm(:,:);


% Build the output struct
channel.chan          = undb10(-totalPathLoss/2) * hUnNorm;
channel.chanTensor    = undb10(-totalPathLoss/2) * hUnNormTensor;
channel.nDelaySamp = nDelaySamp;
channel.nPropDelaySamp = nPropDelaySamp;
channel.dopplerSpreadHz = dopSpread; % (Hz)
channel.nDopplerSamp  = nDopSamp;
channel.hOverSamp   = overSamp;
channel.ricePhaseRad = ricePhaseRad;
if exist('fracDelayFilter', 'var')
  channel.fracDelayFilter = fracDelayFilter;
end

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


