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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


