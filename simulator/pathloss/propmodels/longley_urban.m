function UFdb = longley_urban(dkm,fmhz)
% function UFdb = longley_urban(dkm,fmhz);
% Urban correction factor for Longley-Rice propagation model.
% Suitable when one of Tx/Rx pair is below roof height in urban setting.
% Good for 100 MHz - 3 GHz and distances below 70 km.
% Good for 100 MHz - 500 MHz at distances beyond 70 km.
% Results are pretty much independent of antenna heights.
% From A. G. Longley, Radio Propagation in Urban Areas, US Dept.
% of Commerce/Office of Telecommunications, OT Report 78-144, April 1978. 
% inputs: dkm  = distance, km
%         fmhz = frequency, MHz
% output: UFdb = excess excess-path-loss in dB

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

UFdb = 16.5 + 15*bels(fmhz/100) - 0.12*dkm;

UFdb(UFdb<0) = 0;


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


