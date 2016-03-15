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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get nR, nT, and nL
switch lower(channel.chanType)
  case 'wssus'
    [nR, nT] = size(channel.powerProfile);
    [nL]    = channel.longestLag + 1;
  case {'stfcs','wideband_awgn'}
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


