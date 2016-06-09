function [ GdBi, DdBi ] = stackdp_6_halfWavelength_pd45deg(az, el, fmhz)
% function GdBi = stackdp_6_halfWavelength_pd45deg(az, el, fmhz)
% get antanna gain for an 6-element stacked-dipole array of
% half-wavelength dipoles (lambda/2) with 45 degrees of phase delay
% between elements to point the main lobe at -7 degrees elevation.  The 
% 10dB beamwidth is 14 degrees. 
% All arguments must be scalar or equal sized matrices
% inputs: az = azimuth relative to peak of beam, degrees 
%              (this does nothing, but is needed for standard
%               antenna-gain-function format)
%         el = elevation angle relative to flat earth horizon, degrees
%         fmhz = signal frequency in MHz
% output: GdBi = antenna gain in dB relative to isotropic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check input vector sizes
if ~checkmatscalar(az, el, fmhz);
  error('All non-scalar arguments must be same size, function stackdp_3_1o5');
end

% set constants
NN         = 6;       % number of elements in stack
ll         = 3e8/(fmhz*1e6)/2;  % length of half wavelength dipole, (in meters)
phasedelay = 45;       % phase delay between elements, degrees
Lmatch     = 1.5;     % antenna matching loss, dB
Gmin       = -20;      % minimum antenna gain, dBi
d2r        = pi/180;  % conversion factor, degrees to radians

% get gain 
DdBi = stackdipole(d2r*el, 1e6*fmhz, NN, ll, d2r*phasedelay);
GdBi = DdBi - Lmatch;
GdBi(GdBi<Gmin) = Gmin;


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


