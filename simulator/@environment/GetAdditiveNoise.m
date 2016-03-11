function [noise] = GetAdditiveNoise(env,modRx)

% Function @environment/GetAdditiveNoise.m:
% Wrapper function that generates the additive white Gaussian noise
% seen by the receiver.
%
% USAGE: [env,rxsig] = GetAdditiveNoise(env,nodeRx,modRx)
%
% Input arguments:
%  env       (environment obj) Container for environment parameters
%  modRx     (module obj) Module receiving
%
% Output argument:
%  noise     (MxN complex) Additive noise samples at the module.  
%             M channels x N samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global addGaussianNoiseFlag

KT   = 1.38e-23 * 300; % (Joules) Boltzmann's constant times temp in Kelvin
fs = GetFs(modRx);     % Sample rate of the simulation
fmhz = GetFc(modRx)/1e6; % (MHz) Receiver center frequency
Fint = GetNoiseFigure(modRx); % (dB) internal receiver noise figure
nRx = GetNumAnts(modRx);
req = GetRequest(modRx);
blockLength = req.blockLength;

% get external noise figure
if strncmp(env.envType,'urban',5);              % Urban
   Fext = max(0,manmade(fmhz,'bus'));
elseif strncmp(env.envType,'suburban',5);       % Suburban
   Fext = max(0,manmade(fmhz,'res'));           
elseif strncmp(env.envType,'rural',5);          % Rural
Fext = max(0,manmade(fmhz,'rur'));
end;

if addGaussianNoiseFlag
    % Add noise
    noiseMult = 1;
else
    % No Noise
    noiseMult = 0;
    %disp('Warning: Additive Gaussian noise is not being generated!')
end

% The quantity KT*fs is the thermal noise power per complex sample
%noise = noiseMult*sqrt( KT*fs*(undb10(Fext) + undb10(Fint)) )...
%        *complex(randn(nRx,blockLength), randn(nRx,blockLength))/sqrt(2);
noise = noiseMult*sqrt( 0.5*KT*fs*(undb10(Fext) + undb10(Fint)) )...
        *complex(randn(nRx,blockLength), randn(nRx,blockLength));

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


