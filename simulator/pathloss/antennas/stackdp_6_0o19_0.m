function [ GdBi, DdBi ] = stackdp_6_0o19_0(az, el, fmhz)
% function GdBi = stackdp_6_0o19_0(az, el, fmhz)
% get antanna gain for a 6-element stacked-dipole array of
% 0.1875 m dipoles (lambda/2 at 800 MHz). With no phase delay
% between elements.
% All arguments must be scalar or equal sized matrices
% inputs: az = azimuth relative to peak of beam, degrees 
%              (this does nothing, but is needed for standard
%               antenna-gain-function format)
%         el = elevation angle relative to flat earth horizon, degrees
%         fmhz = signal frequency in MHz
% output: GdBi = antenna gain in dB relative to isotropic

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

% check input vector sizes
if ~checkmatscalar(az, el, fmhz)
  error('All non-scalar arguments must be same size, function stackdp_3_1o5');
end

% set constants
NN         = 6;       % number of elements in stack
ll         = 0.1875;  % dipole length, in m
phasedelay = 0;       % phase delay between elements, degrees
Lmatch     = 1.5;     % antenna matching loss, dB
Gmin       = -20;      % minimum antenna gain, dBi
d2r        = pi/180;  % conversion factor, degrees to radians

% get gain 
DdBi = stackdipole(d2r*el, 1e6*fmhz, NN, ll, d2r*phasedelay);
GdBi = DdBi - Lmatch;
GdBi(GdBi<Gmin) = Gmin;


% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


