function sigma = okumura_sigma(ff, env)
% function sigma = okumura_sigma(ff, env);
% Get shadowing standard deviation from Okumura's propagation data, 
% which is where Hata got his data. But I derived these curves from
% Figure 39 of Okumura's paper.
% These curves were found using data on 100 MHz to 3 GHz
% Range probably varies from 3 km to 80 km (paper is not clear)
% Results are pretty much independent of antenna heights.
% inputs: ff  = frequency, MHz
%         env = environment, 'U' = urban, 'S' = suburban, 
%                            'R' = rural with rolling hills
%         plotflag = 1 then make a plot, default 0
% output: sigma = shadowing standard deviation in dB

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

if strcmp(env, 'U')
  sigma = 1.42 + (203+ff).^(0.234);
elseif strcmp(env, 'S') || strcmp(env, 'R')
  sigma = 2.00 + (291+ff).^(0.259);
else
  error('Unknown environment specifier, function okumura_sigma');
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


