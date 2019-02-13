function NN = manmade(ff,env)
% man-made noise figure curves from ITUR-P.372-8
% input: ff  = frequency in MHz, can be matrix
%        env = environment flag, 'bus' = business area
%                                'res' = residential area
%                                'rur' = rural area
%                                'qru' = quiet rural area
%         
% output: NN = man-made noise figure, dB wrt kToB (To = 290 K)
% results are valid on range 0.3 MHz to 250 MHz, except for business
% area results, which are good up to 900 MHz

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


if strcmp(env,'qru')  % quiet rural model

   NN(ff>=0.3) = 53.6 - 28.6*bels(ff(ff>=0.3));
   NN(ff<0.3)   = nan;

elseif strcmp(env,'rur')  % rural model

   NN(ff>=0.3) = 67.2 - 27.7*bels(ff(ff>=0.3));
   NN(ff<0.3)  = nan;

elseif strcmp(env,'res')  % residential model

   NN(ff>=0.3) = 72.5 - 27.7*bels(ff(ff>=0.3));
   NN(ff<0.3)  = nan;

elseif strcmp(env,'bus')  % business area model
   
   fftrans = 10^((76.8-44.3)/(27.7-12.3)); % transition between models
   NN(ff>=0.3 & ff<=fftrans) = 76.8 - 27.7*bels(ff(ff>0.3 & ff<=fftrans));
   NN(ff>fftrans)  = 44.3 - 12.3*bels(ff(ff>fftrans));
   NN(ff<0.3) = nan;

else

   error('Unknown environment type, function manmade');

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


