function [hTime] = SampleHtensor(channel, ...
                                 propParams, ...
                                 startSamps, ...
                                 sampRate); %#ok - propParams, sampRate unused

% Function channel/SampleHtensor.m:
% Get the impulse response of the channel tensor as a function of time.
%
% USAGE: [hTime, linkInfo] = SampleHtensor(channel, propParams, ...
%                                          startSamps, sampRate)
%
% Input arguments:
%  channel      (struct) Structure containing channel parameters
%   .chanTensor
%   .dopplerSpreadHz
%  propParams   (struct) Structure containing propagation parameters
%   .longestCoherBlock
%   .channelOversamp
%  startSamps   (double array) sample times
%  sampRate     (double) Sample rate
%
% Output arguments:
%  hTime        (nR x nT x nLag x length(startSamps) double) Sampled channel
%
% Example:
%
%  >> fs = 12.5e6; % (Hz) Simulation sample rate
%  >> % Sample the channel every millisecond for .1 seconds
%  >> Ndelta = fs*.001;
%  >> Nend   = fs*.1;
%  >> startSamps = [0:Ndelta:Nend];
%  >> hTime = SampleHtensor(channel, propParams, startSamps, sampRate);

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

DEBUGGING = 0;
SHOWCOUNTER = 0;

% Get parameters from link object
hTensor         = channel.chanTensor;
freqOffs        = channel.freqOffs;
% fd              = channel.dopplerSpreadHz;
% phiOffs         = channel.phiOffs;
% tMax            = channel.longestCoherBlock;
% overSamp        = channel.channelOversamp;

% Get the dimensions of the channel
[nR, nT, nDop, nDelay] = size(hTensor);

% tSampTMaxRatio = 1/(sampRate*tMax);
% freqOffs = (-((nDop-1)/2):((nDop-1)/2) )*tSampTMaxRatio/overSamp;
% if nDop > 1
%     freqOffs = (-((nDop-1)/2):((nDop-1)/2) )*fd*overSamp/sampRate/((nDop - 1)/2);
% else
%     freqOffs = 0;
% end

% Sample the channel at different times
nTimes = length(startSamps);
hTime = zeros(nR, nT, nDelay, nTimes);
for tLoop = 1:nTimes
  if SHOWCOUNTER, disp(['   Sample # ', num2str(tLoop), ...
                       ' out of ', num2str(nTimes)]), end; %#ok if this line is unreachable
  if DEBUGGING, fprintf(1, '\n         '), end; %#ok if this line is unreachable
  startRxChan = startSamps(tLoop);
  for rxLoop = 1:nR % loop through receive antennas
    for txLoop = 1:nT % loop through transmit antennas
      for dopLoop = 1:nDop % loop through Doppler taps
                           % Extract channel impulse response
        h = squeeze(hTensor(rxLoop, txLoop, dopLoop, :));
        h = h(:).';  % Make a row vector

        % nDelay = length(h);
        
        % Calculate convolution with the channel
        if freqOffs(dopLoop) == 0
          zModFilt = h;
        else                       
          % Modulate the data
          zMod = exp(2*pi*freqOffs(dopLoop)*1i*startRxChan);                   
          zModFilt = h.*zMod;
        end
        hTime(rxLoop, txLoop, :, tLoop) ...
            = squeeze(hTime(rxLoop, txLoop, :, tLoop)).' + zModFilt;                    
      end % End loop through doppler taps
      if DEBUGGING, fprintf(1, '.'), end; %#ok if this line is unreachable
    end % end TX antenna loop
      if DEBUGGING, fprintf(1, '\n         '), end; %#ok if this line is unreachable
  end % end RX antenna loop
    if DEBUGGING, fprintf(1, '\n'), end; %#ok if this line is unreachable
    % End filter computation method.
end % end time sample loop


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


