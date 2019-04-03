function [ Ldb, sigmadb ] = ieee802o16(dkm, fmhz, hmm, hbm, env)
% function [ Ldb, sigmadb ] = ieee802o16(dkm, fmhz, hmm, hbm, env)
% Plot mobile system propagation loss using IEEE 802.16 Broadband
% Wireless Access Working Group model, in Channel Models for
% Fixed Wireless Applications, IEEE 802.16.3c-01/29r2, July
% 5, 2001. Much of this is based on Vinko Erceg, Larry J. Greenstein,
% Sony Y. Tjandra, Seth R. Parkoff, Ajay Gupta, Boris Kulic, Arthur
% A. Julius, Renee Bianchi, "An Empirically Based Path Loss Model for
% Wireless Channels in Suburban Environments", IEEE JSAC, Vol. 17,
% No. 7, July 1999, pp 1205-1211. This model does not reflect Erceg's
% treatment of range-loss coefficient and shadow standard deviation
% as random variables. Erceg's results were only for 1900 MHz and
% hmm=2 m, rest is using extensions made up by 802.16 group.
%
% All input parameters may be either scaler, or equal size arrays,
% except env, which must be single-valued
% Parameter	Definition		Units	Range
% dkm		Range			Km	100 m to 8 km
% fmhz		Carrier Frequency	MHz	1900 MHz +/- ?
% hmm    	Mobile Station Height	m	2 - 10 m
% hbm		Base Station Height	m 	10 - 80 m
% env		Ground and Cover Type	none	see Table 1
%
% Table 1: environment
% A	hills and trees
% B     hills or trees
% C	no hills, few trees

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
if nargin<5 || isempty(env)
  env = 'B'; % default
  if nargin<4
    error('Too few input arguments, function ieee802o16');
  end
end
if ~checkmatscalar
  error('All non-scalar arguments must be same size, function ieee802o16');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Erceg's median loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch env
  case('A')
    aa     = 4.6;
    bb     = 0.0075;
    cc     = 12.6;
    musig  = 10.6;
    %siggam = 0.57;
    %sigsig = 2.3;
  case('B')
    aa     = 4.0;
    bb     = 0.0065;
    cc     = 17.1;
    musig  = 9.6;
    %siggam = 0.75;
    %sigsig = 3.0;
  case('C')
    aa     = 3.6;
    bb     = 0.0050;
    cc     = 20;
    musig  = 8.2;
    %siggam = 0.59;
    %sigsig = 1.6;
end

medgamma = aa-bb*hbm+cc./hbm;
medLdb = los(100, fmhz) + medgamma.*db10(dkm/0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mobile height correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(env, 'C')
  Chm = -db20(hmm/2);
else
  Chm = -1.08*db10(hmm/2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frequency correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cf = 6*bels(fmhz/2000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% and finally
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ldb = medLdb + Cf + Chm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% standard deviation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% total variation: within and between cells
%sigmadb = sqrt( (siggam.*db20(dkm/0.1) ).^2 + musig.^2 + sigsig.^2 );

% variation within cell
sigmadb = musig;




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


