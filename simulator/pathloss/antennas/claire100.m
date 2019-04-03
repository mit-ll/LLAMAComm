function [ GdBi, DdBi ] = claire100(az, el, fmhz)
% function GdBi = claire100(az, el, fmhz)
% get antanna gain for a 1.5 m dipole in the direction specified
% by azimuth and elevation variables for signal at frequency fmhz,
% with some serious matching losses at lower frequencies
% This only works for frequencies 100 MHz or lower.
% All arguments must be scalar or equal sized matrices
% inputs: az = azimuth relative to peak of beam, degrees
%              (this does nothing, but is needed for standard
%               antenna-gain-function format)
%         el = elevation angle relative to peak of beam, degrees
%         fmhz = signal frequency in MHz
% output: GdBi = antenna gain in dB relative to isotropic
%         DdBi = antenna directivity in dB relative to isotropic

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

% check input vector sizes
if ~checkmatscalar(az, el, fmhz)
  error('All non-scalar arguments must be same size, function dipole_1o39');
end

if any(fmhz)>110
  error('Frequency outside specified range, function antennas/claire100.m');
end

% set constants
Gpeak  = 6.8*bels(fmhz) - 18.84; % peak antenna gain, dBi
ll     = 1.5; % dipole length, in m
Gmin   = Gpeak-20;    % minimum allowed gain, dBi
D0dBi  = dipole(0, fmhz*1e6, ll); % peak directivity, dBi

% get gain above ground plain
DdBi = dipole(pi*el/180, fmhz*1e6, ll); % directivity dBi
GdBi = Gpeak - D0dBi + DdBi;
GdBi(GdBi<Gmin) = Gmin;


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


