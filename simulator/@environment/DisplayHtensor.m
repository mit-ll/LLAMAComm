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


