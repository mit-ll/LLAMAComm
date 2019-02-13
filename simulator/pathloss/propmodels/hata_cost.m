function L = hata_cost(dkm,fmhz,hmm,hbm,env)
% function L = hata_cost(dkm,fmhz,hmm,hbm,env)
% Plot mobile system propagation loss using Okumura-Hata model
% with the COST-231 range extensions (Digital Mobile Radio Towards
% Future Generation Systems: Cost 231 Final Report, undated)
% COST is for medium and large cities. I have added Hata's
% suburban and rural corrections to include other environments
%
% All input parameters may be either scalar, or equal size arrays
% except env, which must be scalar
% Parameter	Definition		Units	Range		
% dkm		Range			Km	1-20		
% fmhz		Carrier Frequency	MHz	1500-2000	
% hmm		Mobile Station Height	m	1-10		
% hbm		Base Station Height	m 	30-200		
% env           Environment             n/a     see below
% allowed environment values are
%      U2 = urban center
%      U1 = small city or suburb with lots of trees
%      S  = suburb
%      R  = rural
% Model is applicable when base station antenna is taller roof height
% (or other obstructions) within 100 to 200 m

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5 || isempty(env)
  env = 'U1'; % default outside metro center
end 
if nargin<4
  error('Too few input arguments, function hata_cost');
end
if ~checkmatscalar(dkm,fmhz,hmm,hbm)
  error('non-scalar arguments must be same size, function hata_cost');
end
%if ~isscalar(env);
%   error('environment variable must be scalar, function hata_cost');
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's mobile height correction for small cities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ahm = ( 1.1*bels(fmhz) - 0.7 )*hmm - ( 1.56*bels(fmhz) - 0.8 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's model with COST frequency extension
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = 46.3 + 33.9*bels(fmhz) - 13.82*bels(hbm) - ahm + ...
    ( 44.9 - 6.55*bels(hbm) ) .* bels(dkm); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's model with COST frequency and range extensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%L = 46.3 + 33.9*bels(fmhz) - 13.82*bels(hbm) - ahm + ...
%	( 44.9 - 6.55*bels(hbm) ) .* ( bels(dkm)*ones(size(hb)) ).^alpha; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COST Urban center correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(env,'U2')
  L = L + 3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's suburban correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(env,'S')
  Kr = 2 * ( bels(fmhz/28)).^2 + 5.4;
  L = L - Kr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's rural correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(env,'R')
  Qr = 4.78 * ( bels(fmhz) ).^2 - 18.33 * bels(fmhz) + 40.94;
  L = L - Qr;
end





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


