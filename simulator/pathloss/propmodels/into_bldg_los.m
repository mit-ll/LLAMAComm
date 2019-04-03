function LdB = into_bldg_los(do, dp, dd, fmhz, ...
                             h1m, h2m, nwall, canyon, bw); %#ok - bw unused
% function LdB = into_bldg_los(do, dp, dd, fmhz, h1m, h2m, nwall, canyon, bw)
% Find concrete building penetration loss between an external
% antenna (BS) with a line-of-sight view of the building and an
% internal antenna (MS), using the model from the COST 231 final
% report, Section 4.6.2. Positions are given relative to a
% hypothetical penetration point on the building exterior wall
% which is closest to the interior antenna and in the external
% antenna field of view. This point is assumed to be connected
% to the interior antenna by a line perpendicular to the external wall.
% All numerical inputs must be scalar or equal sized matrices, env
% must be single valued
% input:
% do       = length of outdoor line orthogonal to exterior wall, from
%            BS (exterior node) to wall (or extension of wall), m
% dp       = length of line parallel to exterior wall from penetration
%            point to point on wall (or extension) opposite BS, m
% dd       = interior distance from MS to penetration point = point on
%            exterior wall closest to interior node (MS), m
% fmhz     = frequency in MHz
% h2m      = one station antenna height in m, doesn't matter which
% h1m      = other station antenna height in m
% nwall    = number of interior walls between MS and penetration point
%            default 0
% canyon   = environment parameter, 'yes' = urban canyon, default 'no'
% bw       = street width, m, only required if canyon = 'yes'
%
%
%                          |               x MS (indoors)
%                      wall|               |
%                          |             dd|  penetration point
%                          |               | /
%        wall        <---------dp--------->|/
%        extension-->......---------------------------
%                    |               exterior wall
%                    |
%                    |do
%                    |
%                 BS x (outdoors)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if nargin <9 || isempty(bw)
%  bw = 35;
%end
if nargin<8 || isempty(canyon)
  canyon = 'no';
end
if nargin<7 || isempty(nwall)
  nwall=0;
end
if nargin<6 || isempty(h2m)
  h2m = 1;
end
if nargin<5 || isempty(h1m)
  h1m = 8;
end
if nargin<4
  error('Not enough input arguments, function into_bldg_los');
end
if ~checkmatscalar(do, dp, dd, fmhz, h1m, h2m, nwall)
  error('non-scalar arguments must all be same size, function into_bldg_los');
end
if size(canyon, 1)>1
  error('variable canyon must be single valued, function into_bldg_los');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% geometry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(canyon, 'yes') % effective path length from BS to wall
                         % (extension)
  error('model does not currently include urban canyon results');
end
%   do = max( do, min(di, bw/2) ); % half street-width
%   end

rr = sqrt( do.^2 + dp.^2 + (h1m-h2m).^2 ); % length of direct path from
                                           % BS to penetration point
if rr==0
  rr=0.1;
end

theta = asin(do./rr); % direct path grazing angle at exterior wall
if theta < 30*pi/180
  theta = 30*pi/180;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loss at 900 MHz, using COST-231 model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L0 = los(abs(rr+dd), repmat(900, size(fmhz))); % free space loss at 900 MHz

Le = 7; % concrete exterior wall loss, 90 degrees grazing angle, 900 MHz
Lge = 20; % concrete exterior wall loss, 0 degrees grazing angle, 900 MHz
Ltw = Le + Lge.*(1-sin(theta)).^2; % exterior wall loss

Li = 7; % concrete interior wall loss
Gamma1 = nwall*Li;  % excess interior loss due to shadowing/walls
alpha = 0.6;  % indoor loss due to propagating down halls, dB/m
Gamma2 =  alpha*(dd-2).*(1-do./rr).^2; % excess interior loss along hall route
Lib = max(Gamma1, Gamma2); % indoor excess loss

L900dB = L0 + Ltw + Lib; % loss at 900 MHz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frequency correction  from getFreqCorr.m
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

% free-space outdoor loss at 900 MHz, in COST-231 model
%FL900 = repmat(los(rr, 900), size(fmhz));

% free-space outdoor loss at specified frequency, replaces COST-231 term
L0f = los(abs(rr+dd), fmhz);

% frequency corrected loss
LdB = L900dB - L0 + L0f + fcorr;


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


