function DefaultTDCallback(src, ...
                           evt, ...
                           filename, ...
                           fPointer, ...
                           fignum, ...
                           nodename, ...
                           modname, ...
                           fc, ...
                           fs); %#ok - some inputs are unused

% Function td/DefaultTDCallback.m:
% Callback function for rectangles drawn in the timing diagram figure.
% Clicking on one of the rectangles will cause this function to be called.
% This function will plot the signal.
%
% USAGE: Used as a callback function for a drawing/gui object
%          set(objh, 'ButtonDownFcn', ...
%                   {@DefaultTDCallback, ...
%                    filename, fPointer, fignum, nodename, ...
%                    modname, fc, fs, user})
%
% Input arguments:
%  src       (obj handle) Handle to object that triggered callback (unsed)
%  evt       (not used, but required)
%  filename  (string) Path and filename to .cog file
%  fPointer  (int) File offset.  Points to start of a signal block
%  fignum    (int) Figure number of plot to be made
%  nodename  (string) Node name for plot title
%  modname   (string) Module name for plot title
%  fc        (scalar) Center frequency of module
%  fs        (scalar) Sampling rate
%
% *If* the callback has 10 input arguments, then the 10th argument is:
%
%  user      (struct) User parameters at the time this callback was
%             set up.  The callback is set up by
%             @module/UpdateTimingDiagram.m immediately after finishing
%             one of the user-defined module callback functions (the
%             transmit or receive function)
%
% Output arguments:
%  -none-
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


% Open new figure
fh = figure(fignum);
clf(fh);

% Read signal from file
[sig, sSt, sLen, before, bSt, bLen, after, aSt, aLen] = ...
    ReadSigBlockAdj(filename, fPointer);

% Divide plot into subplots, showing up to 12 channels
numChans = size(sig, 1);
if numChans<=6
  m = numChans;
  n = 2;
elseif numChans<=12
  m = ceil(numChans/2);
  n = 4;
else
  warning('DefaultTCCallback:PlotWarning', 'Plotting only first 12 channels.')
  numChans = 12;
  m = ceil(numChans/2);
  n = 4;
end

% Check for complex signal
realOnly = isreal(sig);

% Plot all channels
for c = 1:numChans

  % Plot analog signal
  ah1 = subplot(m, n, (c-1)*2+1, 'Parent', fh);
  plot(sSt:sSt+sLen-1, real(sig(c, :)), 'b', ...
       'LineWidth', 1.5, ...
       'Parent', ah1);
  hold(ah1, 'on');
  set(ah1, 'XLimMode', 'manual');
  if ~realOnly
    plot(sSt:sSt+sLen-1, imag(sig(c, :)), 'g', ...
         'LineWidth', 1.5, ...
         'Parent', ah1);
  end
  if ~isempty(before)
    plot(bSt:bSt+bLen, [real(before(c, :)) real(sig(c, 1))], ...
         'Color', [0 .5 0], ...
         'LineWidth', .5, ...
         'Parent', ah1);
    if ~realOnly
      plot(bSt:bSt+bLen, [imag(before(c, :)) imag(sig(c, 1))], ...
           'Color', [0 0 .5], 'LineWidth', .5, ...
           'Parent', ah1);
    end
    xlim(1) = bSt;
  else
    xlim(1) = sSt;
  end
  if ~isempty(after)
    plot(aSt-1:aSt+aLen-1, [real(sig(c, end)) real(after(c, :))], ...
         'Color', [0 .5 0], ...
         'LineWidth', .5, ...
         'Parent', ah1);
    if ~realOnly
      plot(aSt-1:aSt+aLen-1, [imag(sig(c, end)) imag(after(c, :))], ...
           'Color', [0 0 .5], ...
           'LineWidth', .5, ...
           'Parent', ah1);
    end
    xlim(2) = aSt+aLen-1;
  else
    xlim(2) = sSt+sLen-1;
  end
  xlabel(ah1, 'Samples');
  set(ah1, 'XLim', xlim);
  if c==1
    th = title(ah1, sprintf('%s:%s', nodename, modname));
    set(th, 'Interpreter', 'none');
  end
  yh = ylabel(ah1, sprintf('Chan %d', c)); %#ok - yh unused

  % Plot spectrum
  ah2 = subplot(m, n, 2*c, 'Parent', fh);

  % Spectrogram
  KT   = 1.38e-23 * 300;
  fres = 10e3; % (Hz) Bin resolution
  nfft = min(2^(nextpow2(fs/fres)), 2^11);
  if size(sig, 2) > 4*nfft
    specType = 'spectrogram_toneNormalized'; % 'welch' or 'spectrogram'
  else
    specType = 'welch';
  end

  switch specType
    case 'welch'

      % Spectrum has already been normalized by the sample rate
      %Ps = pwelch(sig(c, :), [], [], [], 1, 'twosided');

      % Spectrum has not been normalized by the sample rate
      Ps = pwelch(sig(c, :), [], [], [], fs, 'twosided');

      % Regular periodogram
      %nfft = 2^nextpow2(length(sig(c, :)));
      %Ps = abs(fft(sig(c, :), nfft)).^2/nfft;

      f = ShiftedFreqScale(length(Ps), fs) + fc;

      sh = plot(f/1e6, db10(fftshift(Ps))+30, ...
                'Parent', ah2); %#ok - sh unused
      xlabel(ah2, 'MHz')
      ylabel(ah2, 'PSD (dBm)');
      title(ah2, sprintf('fc=%.3f MHz', fc/1e6));
      grid(ah2, 'on');
      set(ah2, 'XLimMode', 'manual');
      set(ah2, 'Xlim', [f(1) f(end)]/1e6);


    case 'spectrogram_toneNormalized'
      w = hamming(nfft);
      S = db20(abs(fftshift(spectrogram(sig(c, :)+1i*eps, w), 1)))+30 ...
          -db20(sum(abs(w)));
      minS = db10(KT*fs*norm(w)^2/sum(w)^2);
      maxS = max(max(S(:)), minS+1);
      time = (0:size(S, 2)-1)/fs*(nfft/2);
      f = ShiftedFreqScale(nfft, fs) + fc;
      fres = 1/(sum(w)^2/(norm(w)^2*fs));

      imagesc(time*1e3, f/1e6, S, ...
              'Parent', ah2, ...
              [minS, maxS]);
      axis(ah2, 'xy');
      colorbar
      xlabel(ah2, 'Time (ms)');
      ylabel(ah2, 'Freq (MHz)');
      title(ah2, sprintf('SA output (dBm), fc=%.3f MHz, NBW = %.1f kHz', fc/1e6, fres/1e3));
      grid(ah2, 'on');

    case 'spectrogram_noiseNormalized'
      % Spectrogram
      fres = 10e3; % (Hz) Bin resolution
      nfft = 2^(nextpow2(fs/fres));
      w = hamming(nfft);
      S = db20(abs(fftshift(spectrogram(sig(c, :)+1i*eps, w), 1)))+30 ...
          -db10(norm(w)^2*fs);
      minS = -174;
      maxS = max(max(S(:)), minS+1);
      time = (0:size(S, 2)-1)/fs*(nfft/2);
      f = ShiftedFreqScale(nfft, fs) + fc;

      imagesc(time*1e3, f/1e6, S, 'Parent', ah2, [minS, maxS])
      axis(ah2, 'xy');
      colorbar
      xlabel(ah2, 'Time (ms)')
      ylabel(ah2, 'Freq (MHz)')
      title(ah2, sprintf('PSD (dBm), fc=%.3f MHz', fc/1e6));
      grid(ah2, 'on');

  end % END switch specType

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


