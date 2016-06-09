function [hTime,linkInfo] = GetChannelResponse(env,linkNum,time,sampRate)

% Function env/GetChannelResponse.m:
% Get the impulse response of the channel as a function of time.
%
% USAGE: [hTime, linkInfo] = GetChannelResponse(env,linkNum,startSamps,sampRate)
%
% Input arguments:
%  env          (class environment) environment object
%  linkNum      (int) Index into link array
%  time         (double array) (sec) Channel impulse response start times
%  sampRate     (double) (Hz) Simulation sample rate
%
% Output arguments:
%  hTime        (nR x nT x nLag x length(startSamps) Impulse response
%  linkInfo     (struct) Structure containing link properties
%
% Example:
%
%  >> sampRate = 12.5e6; % (Hz) Simulation sample rate
%  >> linkNum = 1; % Choose one of the links to examine
%  >> % Sample the channel every millisecond for .1 seconds
%  >> time = (0:.001:.1); % (sec)
%  >> hTime = GetChannelResponse(env,linkNum,time,sampRate);
%  >> % Plot the 1st tap of the channel between the 1st Tx and the 1st Rx
%  >> plot(time, squeeze(abs(hTime(1,1,1,:))))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

startSamps = round(time*sampRate);
[hTime,linkInfo] = GetChannelResponse(env.links(linkNum),startSamps);

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


