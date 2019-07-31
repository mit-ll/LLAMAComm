function [hTime] = ChannelImpulseResponse(channel, startSamps)

% Function channel/ChannelImpulseResponse.m:
% Get the impulse response of the channel as a function of time.
%
% USAGE: [hTime] = ChannelImpulseResponse(channel, startSamps, sampRate)
%
% Input arguments:
%  channel      (struct) Structure containing channel parameters
%  startSamps   (int array) Channel impulse response start samples
%
% Output arguments:
%  hTime        (nR x nT x nLag x length(startSamps) Impulse response
%
% Example:
%
%  >> fs = 12.5e6; % (Hz) Simulation sample rate
%  >> % Sample the channel every millisecond for .1 seconds
%  >> Ndelta = fs*.001;
%  >> Nend   = fs*.1;
%  >> startSamps = [0:Ndelta:Nend];
%  >> hTime = SampleChannel(channel, startSamps);
%  >> % Plot the 1st tap of the channel between the 1st Tx and the 1st Rx
%  >> plot(startSamps/fs, squeeze(abs(hTime(1, 1, 1, :))))

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


% Get nR, nT, and nL
switch lower(channel.chanType)
  case 'wssus'
    [nR, nT] = size(channel.powerProfile);
    nL = channel.longestLag + 1;

  case 'wssus-wideband'
    [nR, nT] = size(channel.powerProfile);
    nL = channel.longestLag + 1 + channel.nodeAntSepSamps + (channel.nDelayFiltLen-1);

  case {'stfcs', 'wideband_awgn'}
    [nR, nT, nD, nL] = size(channel.chanTensor); %#ok - nD unused

  case {'los_awgn', 'env_awgn'}
    [nR, nT] = size(channel.riceMatrix);
    nL = 1;
end

% Initialize the loop variables
[nS]    = length(startSamps);
hTime   = zeros(nR, nT, nL, nS);
source  = zeros(nT, 2*nL - 1);

switch lower(channel.chanType)
  case 'wssus'
    for sLoop = 1:nS
      startSamp = startSamps(sLoop);
      for tLoop = 1:nT
        % Set up an impulse from the tLoop antenna
        source(tLoop, nL) = 1;
        %samps = ProcessIidChannel(startSamp, channel, source);
        hTime(:, tLoop, :, sLoop) ...
            = ProcessIidChannel(startSamp, channel, source);
        source(tLoop, nL) = 0; % Set back to zero for the next loop
      end % END tLoop
    end % END sLoop

  case 'wssus-wideband'
    for sLoop = 1:nS
      startSamp = startSamps(sLoop);
      for tLoop = 1:nT
        % Set up an impulse from the tLoop antenna
        source(tLoop, nL) = 1;
        %samps = ProcessIidChannel(startSamp, channel, source);
        hTime(:, tLoop, :, sLoop) ...
            = ProcessIidWBChannel(startSamp, channel, source);
        source(tLoop, nL) = 0; % Set back to zero for the next loop
      end % END tLoop
    end % END sLoop

  case {'stfcs','wideband_awgn'}
    for sLoop = 1:nS
      startSamp = startSamps(sLoop);
      for tLoop = 1:nT
        % Set up an impulse from the tLoop antenna
        source(tLoop, nL) = 1;
        samps = ProcessSampledChannel(startSamp, channel, source);
        hTime(:, tLoop, :, sLoop) = reshape(samps, nR, 1, nL, 1);
        source(tLoop, nL) = 0; % Set back to zero for the next loop
      end % END tLoop
    end % END sLoop

  case {'los_awgn', 'env_awgn'}
    for sLoop = 1:nS
      %startSamp = startSamps(sLoop);
      for tLoop = 1:nT
        % Set up an impulse from the tLoop antenna
        source(tLoop, nL) = 1;
        hTime(:, tLoop, sLoop) = channel.riceMatrix*source;
        source(tLoop, nL) = 0; % Set back to zero for the next loop
      end % END tLoop
    end % END sLoop
end

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
