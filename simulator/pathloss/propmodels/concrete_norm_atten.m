function  na = concrete_norm_atten(f)
% NORMALIZED ATTENUATION OF CONCRETE
% NIST data
% P. Marchand - March 2005
% input:  f = frequency in GHz
% output: na = attenuation in dB per mm of thickness
% result is based on measured attenuation at frequency values
% [0.2:0.1:5.5] GHz, from W. C. Stone, $B!H(BElectromagnetic Signal Attenuation in
% Construction Materials$B!I(B, NISTR 6055, Report No. 3, October 1997, Building and
% Fire Research Laboratory, NIST Gaithersburg Mariland, 20899.
% Results may be somewhat high, as concrete used was fairly new, and concrete
% takes several years to dry thouroughly. Compared, e.g., with theoretical
% results produced by ConcreteSlat_fun.m, these results fall between theoretical
% results for 'wet' and 'saturated' concrete. However, theory also fails to account
% for non-homogeneous nature of actual concrete.

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

Freq_meas   = [0.5  ;1    ;1.500;2    ;2.5  ;3    ;3.5  ;4    ;4.5  ;5.000;5.500];
C_meas =      [0.106;0.133;0.160;0.185;0.210;0.230;0.245;0.255;0.262;0.264;0.265];
%[Pconcrete, S] = polyfit(Freq_meas, C_meas, 5);
Pconcrete = polyfit(Freq_meas, C_meas, 5);
na= polyval(Pconcrete, f);


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


