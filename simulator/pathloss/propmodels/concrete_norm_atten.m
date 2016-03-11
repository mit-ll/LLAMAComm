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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Freq_meas   = [0.5  ;1    ;1.500;2    ;2.5  ;3    ;3.5  ;4    ;4.5  ;5.000;5.500];
C_meas =      [0.106;0.133;0.160;0.185;0.210;0.230;0.245;0.255;0.262;0.264;0.265];
%[Pconcrete, S] = polyfit(Freq_meas, C_meas, 5);
Pconcrete = polyfit(Freq_meas, C_meas, 5);
na= polyval(Pconcrete, f);


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

