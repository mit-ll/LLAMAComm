function [hTime, hTensor] = DisplayHtensor(env, linkIndex, samples, makeplot, fignum)

% Function @environment/DisplayHtensor.m:
% Sample the channel tensor at the given sample times.
%
% USAGE: [hTime, hTensor] = DisplayHtensor(env, linkIndex, samples)
%
% Input arguments:
%  env          (environment obj) Environment object
%  linkIndex    (int) Index of link object to display.
%  samples      (int array) Channel tensor sample times.
%  makeplot     (bool) (optional) Set true if you would like an 
%                      automatically generated scatter plot.  
%                      Default is true.
%  fignum       (int) (optional) You can set the figure number with 
%                      this input
%
% Output arguments:
%  hTime        (double array) This is the samples of the channel
%                   in 4D format: [nR x nT x nL x nT]
%                   where nR is the number of receivers, nT is
%                   the number of transmitters, nL is the number of
%                   lag taps, and nT is the length of 'samples'.
%                   The variable hTime captures the evolution of the
%                   channel taps over time.
%
%  hTensor      (double array) This is the channel tensor generated
%                   by LLAMAComm and used in /@link/PropagateToReceiver.m
%                   to calculate the received signal.
%
% Example:
%
%  >> fs = 12.5e6; % (Hz) Simulation sample rate
%  >> % Sample the channel every millisecond for .1 seconds
%  >> Ndelta = fs*.001;
%  >> Nend   = fs*.1;
%  >> samples = [0:Ndelta:Nend];
%  >> hTime = DisplayHtensor(env, linkIndex, samples);
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global simulationSampleRate

if ~exist('makeplot', 'var')
  makeplot = 1;
end
if ~exist('fignum', 'var')
  fignum = 0;
end

%% Set flags
%plotFroFlag = 0;
%findCohTimeBandwidthFlag = 0;


%% Sample the channel tensor at the given times
[hTime, k] = SampleHtensor(env.links(linkIndex), samples, simulationSampleRate);
hTensor = k.channel.chanTensor;


%---------- THE FOLLOWING CODE IS NOT YET IMPLEMENTED ------------%
%
% if findCohTimeBandwidthFlag
% 
%     % Setup parameters for finding coherence bandwidth and coherence time
% 
%     procParam.cohBandParam = 0.7;     % Linear drop over freq correlation
%     procParam.leftK = 0.1;            % Threshold for cumsum left frequencies
%     procParam.rightK = 0.9;           % Threshold for cumsum right frequencies
%     procParam.Tfactor = 1/4;          % factor to multiply the inverse max Doppler frequency.
%     procParam.Hhat4D = hTime;
%     procParam.Ind = samples;
%     procParam.Nrx = size(hTime, 1);
%     procParam.Ntx = size(hTime, 2);
%     procParam.nTaps = size(hTime, 3);
%     procParam.estType = 'ls';
%     procParam.beginTap = 0;
%     procParam.sampleRate = simulationSampleRate;
%     procParam.chanEstOffset = samples(2) - samples(1);
%     procParam.linkName = k.linkName;
% 
%     procParam.plotCohBandwidthFlag = 1;
%     procParam.plotCohTimeFlag = 1;
%     procParam.plotChanFlag = 0;
%     procParam.plotAllChanFlag = 0;
%     procParam.plotNarrowChanFlag = 0;
% 
% 
%     % Find the coherence time and bandwidth
%     [coherenceTime, coherenceBandwidth] = CohTimeBandwidth(procParam);
% 
% end
%
%----------------------------------------------------------------%

if makeplot
  % Make a scatter plot of all the samples
  [nR, nT, nL, nTimes] = size(hTime); %#ok - nL, nTimes unused
  if fignum
    figure(fignum)
  else
    figure
  end
  for rxLoop = 1:nR
    for txLoop = 1:nT
      subplot(nR, nT, (rxLoop-1)*nT + txLoop)
      data = squeeze(hTime(rxLoop, txLoop, :, :)).';
      plot(real(data), imag(data), 'x-')
      title(['Tx ', num2str(txLoop), ' to Rx ', num2str(rxLoop)])
      axis equal
      grid on
    end
  end
  % set the figure name to the link name
  set(gcf, 'Name', k.linkName)
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


