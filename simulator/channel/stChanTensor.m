function [h,  nSamp,  hTensor] = stChanTensor(alpha, nR, nT,  ...
                                              delaySpread, sampPeriod, overSamp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6
  overSamp = 2;
end

nDecorSamp = round(delaySpread / sampPeriod) + 1;
nSamp      = overSamp * (nDecorSamp-1);

[f, hDec1] = correlatedChannelMatrix(alpha, [nR nT]); %#ok - f unused
hDec(:, :, nDecorSamp) = hDec1; % Preallocate
hDec(:, :, 1) = hDec1;
for chanDecIn = 2:nDecorSamp
  [f, hDec(:, :, chanDecIn)] = correlatedChannelMatrix(alpha, [nR nT]); %#ok - f unused
end


hfm1 = evolveH(0,  hDec(:, :, 1),  hDec(:, :, 2));
hFreqMake(:, :, nSamp) = hfm1; % Preallocate
hFreqMake(:, :, 1) = hfm1;
for sampIn = 2:nSamp
  refIn = floor((sampIn-1)/overSamp) + 1;
  frac  = mod(sampIn-1, overSamp) / overSamp;
  hFreqMake(:, :, sampIn) = ...
      evolveH(frac,  hDec(:, :, refIn),  hDec(:, :, refIn+1));
end

[m1, m2, lenHFreqMake] = size(hFreqMake); %#ok - m1, m2 unused
hTensor = zeros(nR, nT, lenHFreqMake); % Preallocate
for rxIn = 1:nR
  for txIn = 1:nT
    hFreqTemp = reshape(hFreqMake(rxIn, txIn, :), lenHFreqMake, 1);
    hTemp     = fftshift(fft(hFreqTemp));
    %hTemp(1:floor(end/2)) = epsilon*hTemp(1:floor(end/2));
    
    hTensor(rxIn, txIn, :) = reshape(hTemp, 1, 1, lenHFreqMake);
    %hFreq(rxIn, txIn, :) = ...
    %    reshape(ifftshift(ifft(hTemp)), 1, 1, length(hTemp));
  end
end


% h = [];
% [m1, m2, lenHTensor] = size(hTensor); 
% for in = 1:lenHTensor
%   h = [h hTensor(:, :, in) ];
% end
h = hTensor(:, :);



% Copyright (c) 2006-2016,  Massachusetts Institute of Technology All rights
% reserved.
%
% Redistribution and use in source and binary forms,  with or without
% modification,  are permitted provided that the following conditions are
% met:
%      * Redistributions of source code must retain the above copyright
%        notice,  this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above  copyright
%        notice,  this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      * Neither the name of the Massachusetts Institute of Technology nor
%        the names of its contributors may be used to endorse or promote
%        products derived from this software without specific prior written
%        permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL, 
% EXEMPLARY,  OR CONSEQUENTIAL DAMAGES (INCLUDING,  BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  DATA,  OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY,  WHETHER IN CONTRACT,  STRICT LIABILITY,  OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


