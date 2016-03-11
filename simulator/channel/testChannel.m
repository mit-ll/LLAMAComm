% This script tests the channel models used in LLAMAComm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run this script from the /llamacomm/ directory after running
% InitGlobals.m and SetupPaths.m

%% Setup global variables
global includePropagationDelay
global includeFractionalDelay
global randomDelaySpread
includePropagationDelay  = 0;
includeFractionalDelay   = 0;
randomDelaySpread        = 0;  % if 0 then used pre-defined delay spread

%% Environment parameters
envParams.envType            = 'urban'; % 'rural', 'suburban', or 'urban'

%% Propagation parameters
propParams.chanType          = 'iid';  % 'iid' or 'sampled'
propParams.velocitySpread    = 5;      % (m/s)
switch lower(propParams.chanType)
  case 'iid'
    
  case 'sampled'
    propParams.alpha              = 0.7;% Spatial correlation parameter
    propParams.channelOversamp    = 3;  % Channel interpolation parameter
    propParams.longestCoherBlock  = 1;  % (s)
end

%% Path loss parameters
pathLoss.totalPathLoss       = 0;   % (dB) Total pathloss between links
pathLoss.shadowStd           = 4;   % (dB) Log-normal shadow std
pathLoss.shadowCorrLoss      = 0;   % (dB) Shadowloss
pathLoss.riceKdB             = 0;   % (dB) Rice K parameter


%% Transmit node and module properties
modTx.fc            = 800e6;    % (Hz)   Module center frequency
modTx.fs            = 12.5e6;   % (Hz)   Simulation sample rate
modTx.antPosition   = [0      0      0;...
                    1/2    0      0;...
                    3/2    0      0;]*2.998e8/modTx.fc;  % (m)
                                                         %modTx.antPosition   = [0 0 0]; % (m)
nodeTx.location     = [0 0 30]; % (m)


%% Receive node and module properties
modRx.fc            = modTx.fc; % (Hz)    Module center frequency
modRx.fs            = modTx.fs; % (Hz)   Simulation sample rate
modRx.antPosition   = [0      0      0;...
                    1/2    0      0]*2.998e8/modRx.fc;  % (m)
                                                        %modRx.antPosition   = [0 0 0]; % (m)
nodeRx.location     = [0 1000 30]; % (m)


% Get the delay spread
if randomDelaySpread
  1; %#ok if this line is unreachable
  propParams.delaySpread  ...
      = GetDelaySpread(nodeTx, modTx, nodeRx, modRx, envParams, pathLoss);  % (s)
else
  propParams.delaySpread = 1e-6; % (s)
end


%% Get nThrows channel realizations and compute some statistics on them
nThrows = 1;                % Number of channel realizations to throw
channel = cell(1, nThrows);  % Container for channel realizations
longestSpread = 0;          % Used to find the longest channel realization
fs      = modRx.fs;         % Simulation sample rate
hLag = cell(1, nThrows);
for cLoop = 1:nThrows
  
  disp(cLoop)
  
  switch propParams.chanType
    case 'iid'
      % Get the channel parameters
      channel{cLoop} = GetIidChannel(nodeTx, modTx, nodeRx, modRx, ...
                                     propParams, pathLoss);
      if channel{cLoop}.longestLag + 1 > longestSpread
        longestSpread = channel{cLoop}.longestLag + 1;
      end
    case 'sampled'
      % Get the channel parameters
      channel{cLoop} = GetSampledChannel(nodeTx, modTx, nodeRx, modRx, ...
                                         propParams, pathLoss);
      longestSpread = size(channel{cLoop}.chanTensor, 4);
  end
  
  % Compute for each antenna pair the channel impulse response 
  % to a delta input at time 0
  hLag{cLoop} = ChannelImpulseResponse(channel{cLoop}, 0, fs);
end

% Put the channel realizations into one big matrix
hcur = zeros(longestSpread, nThrows);
pProfile = zeros(longestSpread, nThrows);
for cLoop = 1:nThrows
  %[nR, nT, nL, nS] = size(hLag{cLoop});
  nL = size(hLag{cLoop}, 3);
  
  % Stack the instantaneous power-profiles into one matrix
  hcur(1:nL, cLoop) = squeeze(hLag{cLoop}(1, 1, :, 1));
  pProfile(:, cLoop) = abs(hcur(:, cLoop)).^2/norm(hcur(:, cLoop));
end

%% Make some plots

% Plot the mean of the power profile
figure(10)
subplot(211)
stem(0:longestSpread-1, mean(pProfile.', 1))
xlabel('delay (samples)')
ylabel('Power Profile')
grid on
% Plot the mean of the spectral profile
subplot(212)
plot(db10(mean((abs(fft(hcur, [], 1)).^2).')))
grid on
xlabel('frequency (n*fs/N)')
ylabel('Spectral Profile')
drawnow


%% Sample the channel impulse response over time
Ndelta  = fs*0.001;   % Sample the channel every millisecond
Nend    = fs*0.1;       % Sample for 1 second
samps   = 0:Ndelta:Nend; 
nS = length(samps);
nThrowsTime = 1;
hTime = cell(1, nThrowsTime);
for cLoop = 1:nThrowsTime
  hTime{cLoop} = ChannelImpulseResponse(channel{cLoop}, samps, fs);
end

%% Calculate channel realization power for each antenna pair
nR = size(modRx.antPosition, 1);
nT = size(modTx.antPosition, 1);
measuredChanVar = zeros(nR, nT, nThrowsTime);
for rLoop = 1:nR
  for tLoop = 1:nT
    for cLoop = 1:nThrowsTime
      measuredChanVar(nR, nT, cLoop) ...
          = sum(var(squeeze(hTime{cLoop}(rLoop, tLoop, :, :)), [], 2));
    end
  end
end



% Make time-domain plots
figure(11)
f = channel{1}.dopplerSpreadHz*Ndelta/modRx.fs;
[dummy, maxind] = max(hTime{1}(1, 1, :, 1));
c = squeeze(hTime{1}(1, 1, maxind, :));
Lags = min(length(c), round(25/f));
N = 1;
fmfb = f;
Rcc = xcorr(c, c, floor(Lags*N), 'biased');
%Rcc = Rcc/max(Rcc);
Rii = xcorr(real(c), real(c), floor(Lags*N), 'biased');
%Rii = Rii/max(Rii);
Rqq = xcorr(imag(c), imag(c), floor(Lags*N), 'biased');
%Rqq = Rqq/max(Rqq);
Riq = xcorr(real(c), imag(c), floor(Lags*N), 'biased');
%Riq = Riq/max(Riq);
Rqi = xcorr(imag(c), real(c), floor(Lags*N), 'biased');
%Rqi = Rqi/max(Rqi);

x = (0:Lags*N)*fmfb;
subplot(321)
temp = real(Rcc((length(Rcc)+1)/2));
plot(x, real(Rcc((length(Rcc)+1)/2:end)))
title('Rcc b-real, g-imag')
hold on, ...
    plot(x, real(besselj(0, 2*pi*(0:Lags*N)*fmfb))*temp, 'r')
xlabel('Time Delay, fm/fb*t')
plot(x, imag(Rcc((length(Rcc)+1)/2:end)), 'g')
axis tight
grid on
subplot(322)
nfft = max(2^10, 2^nextpow2(length(c)));
plot((-nfft/2:nfft/2-1)/nfft*modRx.fs/Ndelta, ...
     db20(abs(fftshift(fft(c, nfft)))))
title('Doppler Spread')
xlabel('Frequency (Hz)')
grid on
grid on
subplot(323)
plot(x, Rii((length(Rii)+1)/2:end))
title('Rii (b) Rqq (g)')
hold on
plot(x, Rqq((length(Rqq)+1)/2:end), 'g')    
plot(x, .5*real(besselj(0, 2*pi*(0:Lags*N)*fmfb))*temp, 'r')
xlabel('Time Delay, fm/fb*t')
axis tight
grid on
subplot(324)
[nHist, xHist] = hist(abs(c), 50);
plot(xHist, nHist/sum(nHist)/(xHist(2)-xHist(1)))
hold on
varc = var(abs(c));
meanc = mean(abs(c));
r = (0:.01:10*sqrt(varc));
s = sqrt(var(abs(c))*2/(4-pi));
plot(r, r.*exp(-r.^2/(2*s^2))/s^2, 'r--')
title('Histogram of abs(channel)')
xlabel(['channel variance: ', num2str(var(c))])
grid on
subplot(325)
t = samps/fs;
mint = length(c);%floor(min(length(c), 200));
plot(t(1:mint)*1000, db20(abs(c(1:mint))))
hold on
plot([t(1), t(mint)]*1000, db20([meanc, meanc]))
grid on
title('20*log10(abs(c)), Channel Coefficients')
xlabel('time (ms)')
grid on
subplot(326)
plot(x, Riq((length(Riq)+1)/2:end));
title('Riq');
xlabel('Time Delay, fm/fb*t');
grid on

subplot(321), hold off
subplot(322), hold off
subplot(323), hold off
subplot(324), hold off
subplot(325), hold off
subplot(326), hold off

% 
% 
% % Estimate the coherence time and bandwidth
% p.cohBandParam = 1.0;           % linear drop (coherence band parameter)
% p.leftK        = 0.1;           % threshold for cumsum left frequencies
% p.rightK       = 0.9;           % Threshold for cumsum right frequencies
% p.Tfactor      = 1/8;           % factor to multiply the inverse max Doppler frequency.
% p.Hhat4D       = hTime;         % RX-by-TX-by-lag-by-Time channel estimates
% p.Ind          = samps;         % time sample instances
% p.sampleRate   = fs;            % simulation sample rate
% 
% [coherenceTime, coherenceBandwidth] = CohTimeBandwidth(p);


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


