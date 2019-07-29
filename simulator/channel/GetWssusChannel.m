function channel = GetWssusChannel(nodeTx, modTx, nodeRx, modRx, ...
                                   propParams, pathLoss)

% Function 'simulator/channel/GetWssusChannel.m':
% Builds channel struct which contains relevant parameters relating
% to the MIMO link.  All the taps are independent identically distributed.
% with a certain power profile
%
% USAGE:  channel = GetWssusChannel(nodeTx, modTx, nodeRx, modRx, propParams, pathLoss)
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

global includePropagationDelay
global includeFractionalDelay
global DisplayLLAMACommWarnings

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

% Get path power loss (linear)
totalPathLossLin = 10^(pathLoss.totalPathLoss/10);

% Extract number of antennas for link
nT   = size(txnode.antLocation, 1);
nR   = size(rxnode.antLocation, 1);

% Obtain spatial correlation matrices
if(nR > 1)
    rxCorrMat = modRx.rxCorrMat;
    errStr = corrErrCheck(rxCorrMat);
    if(~isempty(errStr))
       error(['Invalid user-defined correlation matrix for module ', modRx.name, ': ', errStr]); 
    end
else
    rxCorrMat = [];
end

if(nT > 1)
    txCorrMat = modTx.txCorrMat;
    errStr = corrErrCheck(rxCorrMat);
    if(~isempty(errStr))
       error(['Invalid user-defined correlation matrix for module ', modTx.name, ': ', errStr]);  
    end
else
    txCorrMat = [];
end

% Get the power profile for each Tx-Rx antenna pair
% Output structure array with the following fields:
%   .pows         - sum(pows) = riceK
%   .lags         - lags ranges from 0 to nLags - 1
%   .riceDelay    - This is the lag for the Rice tap
powerProfile = GetPowerProfile(nodeTx, modTx, nodeRx, modRx, ...
                               propParams, pathLoss, fs);

c         = 2.998e8; % speed of light
dopSpread = propParams.velocitySpread/c* rxnode.fc; % (Hz)

% Specify Doppler profile method for each channel tap
if strcmpi(propParams.chanType, 'los_awgn')
  methodstring = 'los_awgn';
elseif strcmpi(propParams.chanType, 'env_awgn')
  methodstring = 'los_awgn';
elseif dopSpread == 0
  methodstring = 'constant';
else
  methodstring = 'zheng';
end

maxLags = max(cellfun(@length, {powerProfile(:).lags}));

% Obtain the lags of the first antenna-pair profile (as initialization)
nLags = length(powerProfile(1, 1).lags);

% Create a cell array of methods if only a single method is chosen
if ~iscell(methodstring)
    method = cell(nR, nT, maxLags);
    for rLoop = 1:nR
        for tLoop = 1:nT
            if(isempty(txCorrMat) && isempty(rxCorrMat))
                nLags = length(powerProfile(rLoop, tLoop).lags);
            end
            for lLoop = 1:nLags
                method{rLoop, tLoop, lLoop} = methodstring;
            end
        end
    end
end

% Get the initial state of each channel tap over nT, nR, and nL
chanstates = cell(nR, nT);


for rLoop = 1:nR
  for tLoop = 1:nT
    if(isempty(txCorrMat) && isempty(rxCorrMat))
        nLags = length(powerProfile(rLoop, tLoop).lags);
    end
    for lLoop = 1:nLags
      switch lower(method{rLoop, tLoop, lLoop})
        case 'patzold'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 8;
          chanstate.theta1 = 2*pi*rand(chanstate.M, 1);
          chanstate.theta2 = 2*pi*rand(chanstate.M+1, 1);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'zheng'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 8;
          chanstate.theta  = 2*pi*rand(1, 1);
          chanstate.alph   = (2*pi*repmat((1:chanstate.M)', 1, 1) - pi +...
                              repmat(chanstate.theta, chanstate.M, 1))/(4*chanstate.M);
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.sphi   = 2*pi*rand(chanstate.M, 1);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'randangle'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 16;
          chanstate.alph   = 2*pi*rand(chanstate.M, 1);
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'randfreq'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 16;
          chanstate.freqs  = f*(2*rand(chanstate.M, 1) - 1);
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'uniformfreq'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 15;
          chanstate.freqs  = f*linspace(-1, 1, chanstate.M).';
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'uniformfreq_nonuniformprof'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 15;
          chanstate.freqs  = f*linspace(-1, 1, chanstate.M).';
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.varn   = 20;
          chanstate.prof   = sqrt(chanstate.varn)*randn(chanstate.M, 1);
          chanstate.prof   = 10.^(chanstate.prof/10); % Lognormal
          chanstate.prof   = chanstate.prof/sum(chanstate.prof)*chanstate.M;
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'randfreq_nonuniformprof'
          chanstate.doppf  = dopSpread/fs;
          chanstate.M      = 16;
          chanstate.freqs  = f*(2*rand(chanstate.M, 1) - 1);
          chanstate.phi    = 2*pi*rand(chanstate.M, 1);
          chanstate.varn   = 20;
          chanstate.prof   = sqrt(chanstate.varn)*randn(chanstate.M, 1);
          chanstate.prof   = 10.^(chanstate.prof/10); % Lognormal
          chanstate.prof   = chanstate.prof/sum(chanstate.prof)*chanstate.M;
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'constant'
          chanstate.doppf  = dopSpread/fs;
          chanstate.coeff  = complex(randn, randn)/sqrt(2);
          chanstate.method = method{rLoop, tLoop, lLoop};

        case 'los_awgn'
          chanstate.doppf  = dopSpread/fs;
          chanstate.coeff  = 0;
          chanstate.method = 'constant';

        otherwise
          error(['Unknown Doppler spread method: ', method{rLoop, tLoop}])

      end % END switch
      chanstates{rLoop, tLoop}(lLoop) = chanstate;
    end % END lLoop
  end % END tLoop
end % END rLoop

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

% Generate random phase offset
switch propParams.chanType
  case {'los_awgn', 'env_awgn'}
    ricePhaseRad = 0;
  otherwise
    ricePhaseRad = rand*2*pi;
end

% wavelength
lam = c/rxnode.fc;

% Get phase matrix
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

% Specify Rice matrix:
riceMatrix = exp( 1j*(phase + ricePhaseRad) ) / sqrt(totalPathLossLin);

% Normalize the Rice matrix appropriately
%fakeHpow = 1;
%riceMatrix = sqrt(fakeHpow)/norm(riceMatrix, 'fro')*riceMatrix;

% Build the output struct
channel.chanType        = propParams.chanType;
channel.powerProfile    = powerProfile;
channel.longestLag      = FindLongestLag(powerProfile);
channel.riceMatrix      = riceMatrix;
channel.riceKdB         = pathLoss.riceKdB;
channel.chanstates      = chanstates;
channel.nPropDelaySamp  = nPropDelaySamp;
channel.dopplerSpreadHz = dopSpread; % (Hz)
channel.ricePhaseRad    = ricePhaseRad;
channel.rxCorrMat       = rxCorrMat;
channel.txCorrMat       = txCorrMat;

if exist('fracDelayFilter', 'var')
  channel.fracDelayFilter = fracDelayFilter;
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


