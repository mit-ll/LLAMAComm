function [ GdBi, DdBi ] = monopole_0o075(az, el, fmhz)
% function GdBi = monopole_0o075(az, el, fhz)
% get antanna gain for a 7.5 cm  monopole (lambda/4 at f = 1000 MHz)
% in the direction specified by azimuth and elevation variables for signal 
% at frequency fhz.
% 
% All arguments must be scalar or equal sized matrices
% inputs: az = azimuth relative to peak of beam, this does nothing
%         el = elevation angle relative to peak of beam, degrees
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
  error('All non-scalar arguments must be same size, function monopole_0o075');
end

% set constants
Lmatch = 1.5;  % antenna matching loss, dB
lmp    = 0.075;  % monopole length, in m
Gmin   = -20;  % minimum antenna gain, dBi

% assume infinite ground plain
%if el<0 
%  GdBi = Gmin; 
%end

% get gain above ground plain
DdBi = dipole(pi*el/180, fmhz*1e6, 2*lmp);
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


