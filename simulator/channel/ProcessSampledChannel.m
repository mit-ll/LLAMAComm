function rxsig = ProcessSampledChannel(startSamp, channel, source)

% Function simulator/channel/ProcessSampledChannel.m:
% Performs the channel propagation and signal processing according to
% the sampled channel model.  It is called by @link/PropagateToReceiver.m.
%
% USAGE: [rxsig] = ProcessSampledchannel(startSamp, channel, source)
%
% Input arguments:
%  startSamp (int) Channel sample number start
%  channel   (struct) Struct containing channel definition
%  source    (nT x blockLength + nDelay complex)  Transmitted signal
%
% Output argument:
%  rxsig     (nR x N complex) Analog signal received by module.

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

DEBUGGING = 0;

hTensor         = channel.chanTensor;
%tMax            = linkobj.propParams.longestCoherBlock;
freqOffs        = channel.freqOffs;
phiOffs         = channel.phiOffs;
%overSamp        = linkobj.propParams.stfcsChannelOversamp;
[nR, nT, nDop, nDelay] = size(hTensor);
% nDop            = length(freqOffs);
% nDelay          = size(hTensor, 4);

%nSamp = blockLengthRx + nDelay - 1;
nSamp = size(source, 2);

blockLengthRx = nSamp - nDelay + 1;

% Choose computation method: 'fftfilt' or 'filter'
if log2(nSamp) < nDelay
  computationMethod = 'fftfilt';
else
  computationMethod = 'filter';
end

if DEBUGGING
  1; %#ok if this line is unreachable
  fprintf(1, '   ''%s:%s''->''%s:%s:%.2fMHz''\n', ...
          linkobj.fromID{1}, linkobj.fromID{2}, ...
          linkobj.toID{1}, linkobj.toID{2}, linkobj.toID{3}/1e6);
  fprintf(1, ...
          ['      Building receiver data using ''', computationMethod, ''' method.'])
  fprintf(1, '\n         ')
end % END DEGUBBING

%samps = cols(source);
%tSampTMaxRatio = 1/(sampRate*tMax);
%freqOffs = (-((nDop-1)/2):((nDop-1)/2) )*tSampTMaxRatio/overSamp;
%if nDop > 1
%    freqOffs = (-((nDop-1)/2):((nDop-1)/2) )*fd*overSamp/sampRate/(nDop - 1);
%else
%    freqOffs = 0;
%end
rxsig = zeros(nR, blockLengthRx);
switch lower(computationMethod)
  case 'fftfilt'
    % Alternate computation of the STF channel using MATLAB's built-in
    % fftfilt command.
    for rxLoop = 1:nR % loop through receive antennas
      for txLoop = 1:nT % loop through transmit antennas
        for dopLoop = 1:nDop % loop through Doppler taps
                             % Extract channel impulse response
          h = squeeze(hTensor(rxLoop, txLoop, dopLoop, :));
          h = h(:).';  % Make a row vector
                       % Calculate convolution with the channel
          if freqOffs(dopLoop) == 0
            zModFilt = fftfilt(h, source(txLoop, :));
          else
            % Modulate the data
            zMod = exp(1j*(2*pi*freqOffs(dopLoop) ...
                           *(startSamp:startSamp + nSamp - 1) + phiOffs(dopLoop)))...
                   .* source(txLoop, :);
            %                         % Modulate the data
            %                         zMod = exp(2*pi*freqOffs(dopLoop)*i/samps ...
            %                             *[startSamp:startSamp + nSamp - 1])...
            %                             .* source(txLoop, :);
            zModFilt = fftfilt(h, zMod);
          end
          rxsig(rxLoop, :) = rxsig(rxLoop, :) + zModFilt(nDelay:end);
        end % End loop through doppler taps
        if DEBUGGING, fprintf(1, '.'), end; %#ok if this line is unreachable
      end % end TX antenna loop
        if DEBUGGING, fprintf(1, '\n         '), end; %#ok if this line is unreachable
    end % end RX antenna loop
      if DEBUGGING, fprintf(1, '\n'), end; %#ok if this line is unreachable
      % End fft computation method.
  case 'filter'
    % Alternate computation of the STF channel using MATLAB's built-in
    % filter command.
    for rxLoop = 1:nR % loop through receive antennas
      for txLoop = 1:nT % loop through transmit antennas
        for dopLoop = 1:nDop % loop through Doppler taps
                             % Extract channel impulse response
          h = squeeze(hTensor(rxLoop, txLoop, dopLoop, :));
          h = h(:).';  % Make a row vector
          nDelay = length(h);
          % Calculate convolution with the channel
          if freqOffs(dopLoop) == 0
            zModFilt = filter(h, 1, source(txLoop, :));
          else
            % Modulate the data
            zMod = exp(1j*(2*pi*freqOffs(dopLoop) ...
                           *(startSamp:startSamp + nSamp - 1)+ phiOffs(dopLoop)))...
                   .* source(txLoop, :);
            %                        % Modulate the data
            %                         zMod = exp(2*pi*freqOffs(dopLoop)*i/samps ...
            %                             *[startSamp:startSamp + nSamp - 1])...
            %                             .* source(txLoop, :);
            zModFilt = filter(h, 1, zMod);
          end
          rxsig(rxLoop, :) = rxsig(rxLoop, :) + zModFilt(nDelay:end);
        end % End loop through doppler taps
        if DEBUGGING, fprintf(1, '.'), end; %#ok if this line is unreachable
      end % end TX antenna loop
        if DEBUGGING, fprintf(1, '\n         '), end; %#ok if this line is unreachable
    end % end RX antenna loop
      if DEBUGGING
        fprintf(1, '\n'), end; %#ok if this line is unreachable
      % End filter computation method.
  otherwise
    error('Incorrect computation method in propToAn.m: must be either ''fftfilt'' or ''filter''')
end % END switch over computation method

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


