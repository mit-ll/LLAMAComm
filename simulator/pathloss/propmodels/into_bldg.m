function LdB = into_bldg(dd, fmhz, hmm, nwall)
% function LdB = into_bldg(dd, fmhz, hmm, nwall)
% Find concrete building penetration loss between an external
% antenna (BS) with a non-line-of-sight view of the building and an 
% internal antenna (MS), using a combination of
% 1) model from the COST 231 final report, Section 4.6.2. This has
%    results based on geometry, at 900 MHz
% 2) data in Kazimierz Siwiak, Yasaman Bahreini, Radiowave Propagation
%    and Antennas for Personal Communications, 3rd ed., Fig 7.18, which
%    is average over all locations on ground floor, but covers wide range
%    of frequencies
% Result is excess loss, added to outdoor
% propagation loss to a point 2 m above ground level outside the building.
% All numerical inputs must be scalar or equal sized matrices, env 
% must be single valued
% input:
% dd       = interior distance from MS to nearest external wall, assumed
%            to be along line perpendicular to exterior wall
% fmhz     = frequency in MHz
% hmm      = mobile station antenna height in m above outside ground level
% nwall    = number of interior walls between MS and penetration point
%            default 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4 || isempty(nwall)
  nwall=0; 
end
if nargin < 3 || isempty(hmm)
  hmm = 2; 
end
if nargin < 2
  error('Not enough input arguments, function into_bldg');
end
if ~checkmatscalar(dd, fmhz, hmm, nwall);
  error('non-scalar arguments must all be same size, function into_bldg');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loss at 900 MHz using COST-231 model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Le = 7;   % exterior wall loss, concrete wall, normal window size
          % frequency independent at 900 and 1800 MHz
Lge = 4;  % additional exterior wall penetration loss at 900 MHz, because 
          % grazing angle isn't 90 degrees. In multipath, its an
          % integration over multiple angles with some distribution
Li = 7;   % interior wall penetration loss, concrete walls
alpha = 0.6; % indoor loss, dB/m, along hallways
Gamma = max(Li*nwall, alpha*dd); % indoor (exterior wall to MS) loss
Gh = 1.4; % height gain dB/m 
Gfh = Gh*(hmm-2); % height is relative to outdoor reference point
L900dB = Le + Lge + Gamma - Gfh; % penetration + indoor loss at 900 MHz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frequency correction from getFreqCorr.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% coefficients for piecewide linear fit
Blo  = [ -5.25532056521410; 15.46878628093703 ]; % low freq coefficients
flo  = 900; % max frequency for low fit
Bfit = [ -0.52950564461177; 1.50758295075099 ]; % mid freq coefficients
fhi =  3000; % min frequency for high fit
Bhi  = [ 4.57820888757118; -16.25255981214284 ]; % hi freq coefficients

fcorr = zeros(size(fmhz)); % frequency correction
fcorr(fmhz<=flo)           = Blo(2) + Blo(1)*bels(fmhz(fmhz<=flo));
fcorr(fmhz>flo & fmhz<fhi) = Bfit(2) + ...
    Bfit(1)*bels(fmhz(fmhz>flo & fmhz<fhi));
fcorr(fmhz>=fhi)           = Bhi(2) + Bhi(1)*bels(fmhz(fmhz>=fhi));

LdB = L900dB + fcorr;


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


