function h = jakes4(starttime, Nsamples, chanstates, Plot)
% [h, chanstate] = jakes(method, f, Nsamples, starttime, chanstates, Plot)
%
% NSAMPLES is the number of samples you want.
%
% STARTTIME is the time at which you begin channel sampling.  
%
% CHANSTATES is a structure array containing the channel states
%
% PLOT is an argument (1 or 0) which enables plotting of 
%   the time autocorrelation function of each tap.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
  Plot = 0;
end

% Check the dimension of Nsamples, and work accordingly.
Ni = length(chanstates);
t  = (starttime:starttime+Nsamples-1);
h(Ni, Nsamples) = 0; %Allocate. h  = zeros(Ni, Nsamples);

for ii = 1:Ni
  methodfun = chanstates(ii).method;
  f         = chanstates(ii).doppf;  % Dopp freq normalized to sample rate
  
  if strcmpi(methodfun, 'zheng')
    try
      h(ii, :) = zhengFunLUT(f, t, chanstates(ii));
    catch ME; %#ok 
      h(ii, :)    = zheng(f, t, chanstates(ii));      
    end
  else
    h(ii, :)    = eval([methodfun, '(f, t, chanstates(ii));']);
  end
  
  %%%%%%%%%%%%%%%%% Find the Correlation Functions
  if Plot % Make plots
    c = h(ii, :);
    Lags = min(length(c), round(50/f));
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

    %Rqi = xcorr(imag(c), real(c), floor(Lags*N), 'biased');
    %Rqi = Rqi/max(Rqi);

    figure(Plot)% Plot Correlations
    x = (0:Lags*N)*fmfb;
    subplot(321), plot(x, real(Rcc((length(Rcc)+1)/2:end))), title('Rcc b-real, g-imag'), hold on, ...
        plot(x, real(besselj(0, 2*pi*(0:Lags*N)*fmfb)), 'r'), xlabel('Time Delay, fm/fb*t')
    plot(x, imag(Rcc((length(Rcc)+1)/2:end)), 'g'), axis([0, x(end), -.5, 1])
    %subplot(322), plot(x, abs(Rcc((length(Rcc)+1)/2:end))), title('abs(Rcc)'), hold on, ...
    %   plot(x, abs(besselj(0, 2*pi*[0:Lags*N]*fmfb)), 'r'), xlabel('Time Delay, fm/fb*t')
    nfft = max(2^10, 2^nextpow2(length(c)));
    subplot(322), plot((-nfft/2:nfft/2-1)/nfft, db20(abs(fftshift(fft(c, nfft))))), 
    grid on
    subplot(323), plot(x, Rii((length(Rii)+1)/2:end)), title('Rii (b) Rqq (g)'), hold on, ...
        plot(x, .5*real(besselj(0, 2*pi*(0:Lags*N)*fmfb)), 'r'), xlabel('Time Delay, fm/fb*t')
    plot(x, Rqq((length(Rqq)+1)/2:end), 'g'), title('Rqq'), hold on, ...
        plot(x, .5*real(besselj(0, 2*pi*(0:Lags*N)*fmfb)), 'r'), xlabel('Time Delay, fm/fb*t')
    axis([0, x(end), -.3, .5])
    subplot(324), [nHist, xHist] = hist(abs(c), 50);plot(xHist, nHist/sum(nHist)/(xHist(2)-xHist(1))), hold on
    r = 0:.01:3; s = 1/sqrt(2);plot(r, r.*exp(-r.^2/(2*s^2))/s^2, 'r--')
    xlabel(['channel power: ', num2str(var(c))])
    subplot(325), plot(db20(abs(c(1:floor(200))))), grid on, ...
        title('10*log10(abs(c)), Channel Coefficients'), xlabel('t/T')
    subplot(326), plot(x, Riq((length(Riq)+1)/2:end)), title('Riq'), xlabel(['Time', ...
                        ' Delay, fm/fb*t'])
    display('Pausing.  Press any key.')
    pause
  end
end

if Plot
  figure(Plot)
  subplot(321), hold off
  subplot(322), hold off
  subplot(323), hold off
  subplot(324), hold off
  subplot(325), hold off
  subplot(326), hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = zheng(f, t, chanstate)
M      = chanstate.M;
alph   = chanstate.alph;
phi    = chanstate.phi;
sphi   = chanstate.sphi;

h = 2*cos(2*pi*f*cos(alph(1))*t + phi(1)) ...
    + 1j*2*cos(2*pi*f*sin(alph(1))*t + sphi(1));
for I = 2:length(phi);
  h = h + 2*cos(2*pi*f*cos(alph(I))*t + phi(I)) ...
      + 1j*2*cos(2*pi*f*sin(alph(I))*t + sphi(I));
end
h = sqrt(1/(4*M))*h;

% arg1   = 2*cos(2*pi*f*cos(alph)*t + repmat(phi, 1, length(t)));
% arg2   = 2*cos(2*pi*f*sin(alph)*t + repmat(sphi, 1, length(t)));
% h      = sqrt(1/(4*M))*sum(arg1 + j*arg2, 1);
% %h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = patzold(f, t, chanstate)
%Nsin   = chanstate.M;
%theta1 = chanstate.theta1;
%theta2 = chanstate.theta2;
%
%N1     = Nsin;
%N2     = Nsin+1;
%fn1    = f*sin(pi/(2*N1)*((1:N1)'-.5));
%fn2    = f*sin(pi/(2*N2)*((1:N2)'-.5));
%
%arg1   = 2*pi*fn1*t + repmat(theta1, 1, length(t));
%arg2   = 2*pi*fn2*t + repmat(theta2, 1, length(t));
%h      = sqrt(1/N1)*sum(cos(arg1), 1)+1j*sqrt(1/N2)*sum(cos(arg2), 1);
%%h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = randangle(f, t, chanstate)
%M      = chanstate.M;
%alph   = chanstate.alph;
%phi    = chanstate.phi;
%
%arg    = exp(1j*(2*pi*f*cos(alph)*t + repmat(phi, 1, length(t))));
%h      = sqrt(1/M)*sum(arg, 1);
%%h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = randfreq(f, t, chanstate)
%M      = chanstate.M;
%freqs  = chanstate.freqs;
%phi    = chanstate.phi;
%
%arg    = exp(1j*(2*pi*freqs*t + repmat(phi, 1, length(t))));
%h      = sqrt(1/M)*sum(arg, 1);
%%h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = uniformfreq(f, t, chanstate)
%M      = chanstate.M;
%freqs  = chanstate.freqs;
%phi    = chanstate.phi;
%
%arg    = exp(1j*(2*pi*freqs*t + repmat(phi, 1, length(t))));
%h      = sqrt(1/M)*sum(arg, 1);
%%h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = freqs_nonuniformdopp(f, t, chanstate)
%M      = chanstate.M;
%freqs  = chanstate.freqs;
%phi    = chanstate.phi;
%prof   = chanstate.prof;
%
%arg    = exp(1j*(2*pi*freqs*t + repmat(phi, 1, length(t))));
%h      = sqrt(1/M)*sum(arg.*repmat(sqrt(prof), 1, size(arg, 2)), 1);
%%h     = (h-mean(h))/std(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function h = constant(f, t, chanstate)
%h = repmat(chanstate.coeff, 1, length(t));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


