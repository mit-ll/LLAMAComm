function channel = GetGeometricChannel(nodeTx,modTx,nodeRx,modRx,...
                                   propParams,pathLoss)

% Function 'simulator/channel/GetGeometricChannel.m':  
% Builds channel struct for geometric propagation with time delays between transmit
% and receive antennas with line of site loss. 
%
% The channel is constructed so that the bulk delay plus the
% delay in the channel filters is geometrically correct.
%
% USAGE:  channel = GetGeometricChannel(nodeTx,modTx,nodeRx,modRx,propParams,pathLoss)
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
%
% WARNING! The following parameter components are ignored:
%  propParams.stfcsChannelOversamp
%  pathLoss.riceKdB
%  propParams.longestCoherBlock
%  propParams.velocitySpread
% There may be others.
%
% includeFractionalDelay is unused since the fractional delay is always rolled into the channel
% regardless of the state of the global variable.
%
% The filters used for fractional delay are really only good to about half the Nyquist bandwidth.

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
%global includeFractionalDelay

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
%riceKdB       = pathLoss.riceKdB;

% Get the simulation sample rate
fs = modRx.fs;

%overSamp = propParams.stfcsChannelOversamp; % Not supporting overSamp, we ignore this parameter

% Extract number of antennas for link
nT   = size(txnode.antLocation,1);
nR   = size(rxnode.antLocation,1);

%tMax = propParams.longestCoherBlock; % Ignoring this

c_light=299792458; % m/s
%dopSpread = propParams.velocitySpread/c_light* rxnode.fc; % (Hz) Not used

% Calculate the relative delays for each tx,rx pair
% Take out the minimum delay in integer samples and optionally save this as nPropDelaySamp
% Roll the fractional delay into the channel filters

% FIXME, antenna pattern opportunity. Right around here would be a good place to fold in transmit and receive element
% patterns

% Get delays matrix
delays = zeros(nR,nT); % line of sight propagation delay (seconds)
for rxLoop=1:nR % index Rx
                % Receive antenna location
  rxAntLoc = mic2mac(rxnode.location,rxnode.antLocation(rxLoop,:));
  for txLoop=1:nT % index Tx
                  % Transmit antenna location
    txAntLoc = mic2mac(txnode.location,txnode.antLocation(txLoop,:));
    delays(rxLoop,txLoop) = norm(rxAntLoc-txAntLoc)./c_light; % range between tx and rx antennas
  end
end

minDelay = min(delays(:));
maxDelay = max(delays(:));

nDelayFilters = 15;
halfDelay=(nDelayFilters-1)/2; % in samples
bulkDelaySamp = floor(minDelay * fs - halfDelay); % should be <= minDelay * fs
bulkDelay = bulkDelaySamp / fs; % so the fractional delay and filter delay is all rolled into the channel filters

if includePropagationDelay
    nPropDelaySamp = bulkDelaySamp;
else
    nPropDelaySamp = 0;
end

chanTimeTaps = ceil(maxDelay * fs - bulkDelaySamp + halfDelay + 2);
% Make the prototype Farrow filter
farrowDesign = fdesign.fracdelay(0.24,'N',nDelayFilters);
farrow = design(farrowDesign,'lagrange','FilterStructure','farrowfd');

hTensor = zeros(nR,nT,1,chanTimeTaps); % This will have unit direct-path gain and then be scaled by pathloss at the end
for rxLoop = 1:nR
    for txLoop = 1:nT
        delaySamples = delays(rxLoop,txLoop) * fs - bulkDelaySamp;
        fracDelay = delaySamples - floor(delaySamples);
        farrow.FracDelay=fracDelay;
        ind = floor(delaySamples) - halfDelay;
        phase = 2*pi * rxnode.fc * (delays(rxLoop,txLoop) - bulkDelay); % phase contribution from the complex carrier
        if fracDelay < eps
            hTensor(rxLoop,txLoop,1,floor(delaySamples)) = exp(1i*phase);
        elseif fracDelay > 1 - eps
            hTensor(rxLoop,txLoop,1,floor(delaySamples)+1) = exp(1i*phase);
        else
            hTensor(rxLoop,txLoop,1,ind+1:ind+nDelayFilters) = exp(1i*phase) .* ...
                filter( farrow, [1 zeros(1,nDelayFilters-1)] );
        end
    end
end

% Common, random phase offset
phase=2*pi*rand(1);

% Build the output struct
%channel.chan              = undb10(-totalPathLoss/2) * hUnNorm; % unused by other code?
channel.chanTensor        = undb10(-totalPathLoss/2) * exp(1i*phase) .* hTensor;
%channel.fakeHpow          = fakeHpow; % unused by other code
channel.nDelaySamp        = chanTimeTaps; % guessing that this is the right number to pass out
channel.nPropDelaySamp    = nPropDelaySamp;
%channel.longestCoherBlock = propParams.longestCoherBlock; % we said we were ignoring this
channel.dopplerSpreadHz   = 0; % (Hz)
channel.nDopplerSamp      = 1;
%channel.hOverSamp         = overSamp; % ignored
%channel.stfcsChannelOversamp   = propParams.stfcsChannelOversamp; % ignored
%channel.ricePhaseRad      = ricePhaseRad; % unused
channel.freqOffs          = 0; % Can be an array
channel.phiOffs           = 0; % Can be an array
channel.chanType          = propParams.chanType;

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


