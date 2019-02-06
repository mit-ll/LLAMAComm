function powerProfile = GetPowerProfile(nodeTx, modTx, nodeRx, modRx, ...
                                        propParams, pathLoss, fs)

% Function 'simulator/channel/GetPowerProfile.m':  
% Builds diffuse channel power profile for each Tx-Rx antenna pair based
% on the assumption that the power profile is exponentially decaying.
% Assumes the probability that a given tap is active is proportional to
% the power in the given tap.
%
% USAGE:  powerProfile = GetPowerProfile(nR, nT, propParams)
%
% Input arguments:
%  nodeTx           (struct) Node transmitting
%  modTx            (struct) Module transmitting
%  nodeRx           (struct) Node receiving
%  modRx            (struct) Module receiving
%  propParams       (struct) Structure containing Propagation parameters
%  pathLoss         (struct) Structure containing path loss parameters
%  fs               (double) (Hz) Simulation sample rate
%
% Output argument:
%  powerProfile     (nR, nT struct matrix) struct containing delay spread 
%                           power profiles for each Tx-Rx antenna pair.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get path power loss (linear)
totalPathLossLin = 10^(0.1*pathLoss.totalPathLoss);

% Build transmitter node struct
txnode.location = nodeTx.location;
txnode.antLocation = modTx.antPosition;
txnode.fc = modTx.fc;

% Build receiver node struct
rxnode.location = nodeRx.location;
rxnode.antLocation = modRx.antPosition;
rxnode.fc = modRx.fc;

% Extract number of antennas for link
nT   = size(txnode.antLocation, 1);
nR   = size(rxnode.antLocation, 1);

% Check if 'los_awgn' channel type has been specified
if any(strcmpi(propParams.chanType, {'los_awgn', 'env_awgn'}))
  powerProfile = repmat(struct('pows', 1/totalPathLossLin, ...
                               'lags', 0, ...
                               'riceLag', 0), ...
                        [nR, nT]);
  return
end

if ~isempty(propParams.wssusChannelTapSpacing)
  tapSpacing = propParams.wssusChannelTapSpacing;
else
  tapSpacing = 1;
end

% Get the rms delay spread in number of samples
%delaySpread = propParams.delaySpread*fs/tapSpacing;

% Limit the number of possible taps
maxNumLags = 20;

% Get the RMS delay spread in terms of taps
lambda = propParams.delaySpread*fs/tapSpacing;

% Set the power level of the smallest possible tap relative to the
% first tap
minRelPow = 1e-4; % min tap power -40 dB relative to first tap power
maxLagIndex = -lambda*log(minRelPow); % Largest possible lag index
if maxLagIndex < 1
    maxLagIndex = 1;
end

% Allocate structure array
powerProfile(nR,nT) = struct('pows', 0, ...
                             'lags', 0, ...
                             'riceLag', 0, ...
                             'measuredRMSdelaySpread', 0);

nThrows = 1000;
for rLoop = 1:nR
  for tLoop = 1:nT
    
    % Make the probability that a tap is active based on the power
    % level of the tap.  This will create power profiles that are
    % increasingly sparse at greater lag indices.
    % Do 1000 trials to calculate random lag indices. Stop when
    % maxNumLags unique lags have been drawn
    lags = zeros(1, maxNumLags);
    lagInd = 1;
    for I = 1:nThrows
      
      % Generate a random sample from an exponential distribution and
      % round to the nearst integer tap lag
      cdfx = rand*(1-minRelPow);  % limit to minRelPow power
      lag = round(-lambda*log(1-cdfx));

      % Remove redundant lag locations and make sure 0 is a tap location
      if ~any(lags(1:lagInd) == lag)
        lagInd = lagInd + 1;
        lags(lagInd) = lag;
      end
     
      % Check to see if we have maxNumLags number of lags
      if lagInd == maxNumLags
        break
      end
    end

    if lagInd < maxNumLags
      % Order the lags from smallest to largest
      lags = sort(lags(1:lagInd), 'ascend');
    else
      % Order the lags from smallest to largest
      lags = sort(lags, 'ascend');      
    end      
    
    
    % Calculate the power profile and normalize to unit power.
    % Include a fudge factor to decrease the power roll off
    % because we are enforcing a sparse power profile.
    fudgeFactor = maxLagIndex/maxNumLags;  
    pows = 1/(lambda+fudgeFactor)*exp(-1/(lambda+fudgeFactor)*lags);
    pows = pows/sum(pows);
    
    % Calculate the RMS delay spread of the given power profile
    meanSpread = sum(lags.*pows);
    measuredRMSdelaySpread = sqrt(sum((lags-meanSpread).^2.*pows));
    
    % Make a plot of the power
    if 1==0
      pows_normMin_dB = db10(pows/pows(end));
      stem(lags, pows_normMin_dB)
      hold('on');
      plot([lambda, lambda], [0, pows_normMin_dB(1)], 'g')
      plot([spreadRMS, spreadRMS], [0, pows_normMin_dB(1)], 'r');
      grid('off');
      hold('off');      
      legend('Power Profile', ...
             'Target RMS delay spread', ...
             'Measured RMS Delay Spread');
    end
    
    % Include the total path loss into the power profile
    pows = pows/totalPathLossLin;
    
    % The profile is exponential, so place the Rice tap at zero lag
    riceLag = 0;
    
    % Create the struct
    powerProfile(rLoop, tLoop).pows = pows;
    powerProfile(rLoop, tLoop).lags = lags*tapSpacing;
    powerProfile(rLoop, tLoop).riceLag = riceLag;
    powerProfile(rLoop, tLoop).measuredRMSdelaySpread ...
        = measuredRMSdelaySpread*tapSpacing/fs;
  end
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


