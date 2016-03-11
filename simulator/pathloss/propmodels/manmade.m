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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if strcmp(env,'qru'); % quiet rural model

   NN(ff>=0.3) = 53.6 - 28.6*bels(ff(ff>=0.3));
   NN(ff<0.3)   = nan;

elseif strcmp(env,'rur');  % rural model

   NN(ff>=0.3) = 67.2 - 27.7*bels(ff(ff>=0.3));
   NN(ff<0.3)  = nan;

elseif strcmp(env,'res');  % residential model

   NN(ff>=0.3) = 72.5 - 27.7*bels(ff(ff>=0.3));
   NN(ff<0.3)  = nan;

elseif strcmp(env,'bus');  % business area model
   
   fftrans = 10^((76.8-44.3)/(27.7-12.3)); % transition between models
   NN(ff>=0.3 & ff<=fftrans) = 76.8 - 27.7*bels(ff(ff>0.3 & ff<=fftrans));
   NN(ff>fftrans)  = 44.3 - 12.3*bels(ff(ff>fftrans));
   NN(ff<0.3) = nan;

else

   error('Unknown environment type, function manmade');

end;


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


