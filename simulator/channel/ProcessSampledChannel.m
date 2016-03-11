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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


