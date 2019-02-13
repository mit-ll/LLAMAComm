function zStf = stfStackIndexed(z, ...
                                nDelay, delayIndex, ...
                                nFreq, freqIndex, ...
                                tSampTMaxRatio, ...
                                freqOverSamp, ...
                                sampOffset); %#ok - nDelay unused
%
%  This function produces random space-time-frequency channel matrices 
%  with a give spatial correlation.  This function is designed to be 
%  used with stfChanTensor.
%
% Outputs
%  zSTF      - stf channel matrix 

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


samps = cols(z) ;

zST = Stackzs(z,delayIndex-1) ;

freqOffs = (-((nFreq-1)/2):((nFreq-1)/2) )*tSampTMaxRatio/freqOverSamp ;

zStf = repmat(exp(2*pi*freqOffs(freqIndex)*1i/samps ...
    *((0+sampOffset):(samps-1+sampOffset))), rows(z),1) .* zST ;


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


