function SFdb = longley_suburban(dkm, fmhz)
% function SFdb = longley_suburban(dkm, fmhz);
% Suburban correction factor for Longley-Rice propagation model.
% Suitable when one of Tx/Rx pair is below roof height in urban setting.
% Good for 150 MHz - 2 GHz and distances below 20 km.
% Results are pretty much independent of antenna heights.
% Similar to A. G. Longley, Radio Propagation in Urban Areas, US Dept.
% of Commerce/Office of Telecommunications, OT Report 78-144, April 1978, 
% but different.
% inputs: dkm  = distance, km
%         fmhz = frequency, MHz
% output: SFdb = excess excess-path-loss in dB

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


[dd, ff] = matsize(dkm, fmhz);
if isnan(dd)
  error('Non-scalar inputs must be same size');
end

off = zeros(size(dd));
off(dd<4)  = 7.472 + 1.193*dd(dd<4);
off(dd>=4) = 12.976 - 0.13*dd(dd>=4);

slope = zeros(size(dd));
slope(dd<9)  = 1.44 + 0.57*dd(dd<9);
slope(dd>=9) = 6.719 - 0.053*dd(dd>=9);

SFdb = off + slope.*bels(ff/100);

SFdb(SFdb<0) = 0;


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


