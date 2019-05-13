function [rxsig] = ProcessIidWBChannel(startSamp, channel, source)

% Function simulator/channel/ProcessIidWBChannel.m:
% Performs the channel propagation and signal processing according to
% the iid channel model.  It is called by @link/PropagateToReceiver.m.
%
% USAGE: [rxsig] = ProcessIidWBChannel(startSamp, channel, source)
%
% Input arguments:
%  startSamp (int) Channel sample number start
%  channel   (struct) Struct containing channel definition
%  source    (nT x blockLength + nDelay complex)  Transmitted signal
%
% Output argument:
%  rxsig     (nR x N complex) Analog signal received by module.  

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


% Specify the number of receivers and transmitters
[nR, nT] = size(channel.powerProfile);
nodeAntSepSamps = channel.nodeAntSepSamps;

% Specify the number of output samples per Rx antenna
nS = size(source, 2) - channel.longestLag - (channel.nDelayFiltLen-1) - nodeAntSepSamps;

if nS < 1
    error('The source length: %d is less than the longest channel length: %d', ...
          num2str(size(source, 2)), ...
          num2str(channel.longestLag+1));
end

chanstates = channel.chanstates;
riceKlin   = 10^(0.1*channel.riceKdB);
if riceKlin > 1e8
    % This is a hack so that riceKlin -> infinity is handled
    riceKlin = 1e8;
end

% transpose the source so multiplication works out
source = source.';

nS_ones = ones(1, nS);
longestLag = channel.longestLag;
powerProf = channel.powerProfile;
riceMat = sqrt(riceKlin/(riceKlin + 1))*channel.riceMatrix;

% Get info about 
nDelayFiltLen = channel.nDelayFiltLen;
delayFiltHalfLen = (nDelayFiltLen-1)/2;
tDelayFilt = -delayFiltHalfLen:delayFiltHalfLen;

rxtxDOF = nR*nT;
allSigs = zeros(rxtxDOF, nS);

% Loop over transmit/receive pairs
for rxtxLoop = 1:rxtxDOF

    % Get transmitter and receiver out of the combined rxtx indexing
    rxIndx = 1 + mod(rxtxLoop-1, nR);
    txIndx = 1 + floor((rxtxLoop-1)/nR);
    
    
    chanstate = chanstates{rxtxLoop};
    pprof = powerProf(rxtxLoop);
    
    % Generate time-varying channel
    H = jakes4(startSamp, nS, chanstate);
    
    % Apply power profile
    pows = pprof.pows /(riceKlin + 1);
    H = H.*(sqrt(pows(:))*nS_ones); 

    % Add the Rice tap 
    H(1+pprof.riceLag, :) = H(1+pprof.riceLag, :) + riceMat(rxIndx, txIndx);

    % Get ready for convolution
    H = H.';
    
    % offsetDelaySamp is the delay (in samples) to the antenna with the bulk
    % (integer part of the smallest delay) removed:
    offsetDelaySamp = channel.offsetDelayMatrix(rxIndx, txIndx); 
    
    % Decompose offsetDelaySamp into integer and fractional parts:
    dFix = fix(offsetDelaySamp); % Integer part of the delay (0 for the closest antenna)
    dFrac = offsetDelaySamp - dFix; % Fractional part of the delay

    % Construct fractional delay filter
    fracDelayFilter = sinc(tDelayFilt - dFrac);

    %% Apply fractional delay filter 
    %src = conv(source(:, txIndx), fracDelayFilter);   
    %
    %% Keep the "valid" portion by stripping off (nDelayFiltLen-1)
    %% samples from both sides added by performing the convolution, 
    %% Note the extra 0.5*(nDelayFiltLen-1) early samples fetched
    %% in "PropagateToReceiver" guarantee that the first and last
    %% outputs of filtering+trimming correspond to the first and 
    %% last filtered samples.
    %src = src((1+(2*delayFiltHalfLen)):end-(2*delayFiltHalfLen));

    % Apply fractional delay filter and strip off 'invalid' portion
    % (This is equivalent to the conv and chop commented out above)
    src = conv(source(:, txIndx), fracDelayFilter, 'valid');   
         
    % Remove extra samples added to the beginning
    % (Antennas with later delays have fewer samples removed)
    src = src(1+(nodeAntSepSamps-dFix):end);
    
    % Apply channel matrix
    allSigs(rxtxLoop, :) = TVConv(H, pprof.lags, src, longestLag); 

end % END rxtxLoop

rxsig = reshape(sum(reshape(allSigs, [nR, nT, nS]), 2), [nR, nS]);
allSigs = []; %#ok - allSigs no longer needed 

% Do the Rice tap
%inds = (1:nS) + channel.longestLag - channel.powerProfile(1, 1).riceLag;
%source = source.';  % Flip the source back
%riceMat = sqrt(riceKlin/(riceKlin + 1))*channel.riceMatrix;
%rxsig = rxsig + riceMat*source(:, inds);

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
