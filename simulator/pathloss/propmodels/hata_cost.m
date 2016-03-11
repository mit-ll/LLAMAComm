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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5 || isempty(env)
  env = 'U1'; % default outside metro center
end 
if nargin<4;  
  error('Too few input arguments, function hata_cost');
end
if ~checkmatscalar(dkm,fmhz,hmm,hbm);
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

if strcmp(env,'U2');
  L = L + 3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's suburban correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(env,'S');
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


