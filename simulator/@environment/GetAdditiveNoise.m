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

global addGaussianNoiseFlag

KT   = 1.38e-23 * 300; % (Joules) Boltzmann's constant times temp in Kelvin
fs = GetFs(modRx);     % Sample rate of the simulation
fmhz = GetFc(modRx)/1e6; % (MHz) Receiver center frequency
Fint = GetNoiseFigure(modRx); % (dB) internal receiver noise figure
nRx = GetNumAnts(modRx);
req = GetRequest(modRx);
blockLength = req.blockLength;

% get external noise figure
switch(env.envType)
  case 'urban'
    Fext = max(0,manmade(fmhz,'bus'));
  case 'suburban'
   Fext = max(0,manmade(fmhz, 'res'));
  case 'rural'
    Fext = max(0,manmade(fmhz,'rur'));
  case 'airborne'
    Fext = 0;
  otherwise
    error('Unknown environment type: %s', env.envType)
end

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


