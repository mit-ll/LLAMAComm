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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[ dd ff ] = matsize(dkm, fmhz);
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


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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


