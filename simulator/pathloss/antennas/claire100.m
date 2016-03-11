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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check input vector sizes
if ~checkmatscalar(az, el, fmhz);
  error('All non-scalar arguments must be same size, function dipole_1o39');
end

if any(fmhz)>110;
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

