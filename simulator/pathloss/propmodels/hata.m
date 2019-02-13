function L = hata(dkm,fmhz,hmm,hbm,cover)
% function L = hata(dkm,fmhz,hmm,hbm,cover)
% Plot mobile system propagation loss using Okumura-Hata model
% from Hata, VTC 1980, pp 317-325, 
% Formerly this had range, frequency, and ground
% cover extensions from RACE Mobile Telecommunications Project R1043
% (REF:RMTP/CC/R157, Issue 1.1, London 12/18/91), but now it's just hata
% My former hata+race is in hata_race.m, orthodox race is in race.m
%
% All input parameters may be either scalar, or equal size arrays,
% except cover, which must be single-valued
% Parameter	Definition		Units	Range		
% dkm		Range			Km	1-20		
% fmhz		Carrier Frequency	MHz	150-1500	
% hmm    	Mobile Station Height	m	1-10		
% hbm		Base Station Height	m 	30-200		
% cover		Ground Cover Type	none	see Table 1 	
%
% Model is applicable when base station antenna is taller roof height
% (or other obstructions) within 100 to 200 m
%
% Table 1: cover
% S	suburban
% R     rural
% U1	urban, low density -- buildings < 5 stories, moderate density
% U2	urban -- avg. 5 story buildings, up to 10 stories, moderate density

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
if nargin<5 || isempty(cover)
  cover = 'U1'; % default 
end 
if nargin<4
  error('Too few input arguments, function hata');
end
if ~checkmatscalar(dkm,fmhz,hmm,hbm)
  error('non-scalar arguments must be same size, function hata');
end
if ~( all(size(cover)==[1 1]) || all(size(cover)==[1 2]) )
  error('environment variable must be single-valued, function hata');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's mobile height correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(cover,'U2') % buildings >= 5 stories
  if fmhz<=200
      ahm = 8.29*( bels( 1.54*hmm) ).^2 - 1.1;
  else	   
      ahm = 3.2 *( bels(11.75*hmm) ).^2 - 4.97;
  end
else
  ahm = ( 1.1*bels(fmhz) - 0.7 )*hmm - ( 1.56*bels(fmhz) - 0.8 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's basic urban loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = 69.55 + 26.16*bels(fmhz) - 13.82*bels(hbm) - ahm + ...
    ( 44.9 - 6.55*bels(hbm) ) .*  bels(dkm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's suburban correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(cover,'S')
  Kr = 2 * ( bels(fmhz/28)).^2 + 5.4;
  L = L - Kr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hata's rural correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(cover,'R')
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


