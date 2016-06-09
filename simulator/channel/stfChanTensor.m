function [hCorNorm, nDelaySamp, nDopSamp, hTensorCorNorm, fakeHpow] ...
    = stfChanTensor(alpha, nR, nT, ...
                    delaySpread, sampPeriod, overSamp, ...
                    dopplerSpread, blockPeriod, overDopSamp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 9
  overDopSamp = 2;
  if nargin < 8 
    blockPerod = 1e-10; %#ok - unused
    if nargin < 7
      dopplerSpread = 0;
      if nargin < 6
        overSamp = 2;
      end
    end
  end
end

% calculate number of samples in transformed domain -------------
nDecorFreqSamp = round(delaySpread / (sampPeriod*overSamp)) + 1;
nFreqSamp      = max(overSamp * (nDecorFreqSamp-1), 1);
nDecorTimeSamp = round(dopplerSpread * blockPeriod) + 1;
nTimeSamp      = max(overDopSamp * (nDecorTimeSamp-1), 1);


% build decorrelated samples in transform domain ----------------
[f, hDec1] ...
    = correlatedChannelMatrix(alpha, [nR nT]); %#ok - f unused
hDec((nDecorTimeSamp+1), (nDecorFreqSamp+1)) = hDec1; % Preallocate
hDec(1,1) = hDec1;
for kk = 2:((nDecorFreqSamp+1)*(nDecorTimeSamp+1))
  [f, hDec(kk)] ...
      = correlatedChannelMatrix(alpha, [nR nT]); %#ok - f unused
end

% Preallocate
[f, hFreqRefs((nDecorTimeSamp+1),nFreqSamp)] = evolveH(0, hDec(1,1), hDec(1,2)); %#ok -f unused

% build oversampled channel in transform domain -----------------
% start by building finely in Freq direction
for sampFreqIn = 1:nFreqSamp
  for decorTimeIn = 1:(nDecorTimeSamp+1)
    
    refFreqIn = floor((sampFreqIn-1)/overSamp) + 1;
    frac      = mod(sampFreqIn-1, overSamp) / overSamp;
    
    [f, hFreqRefs(decorTimeIn, sampFreqIn)] = ...
        evolveH(frac, ...
                hDec(decorTimeIn, refFreqIn), ...
                hDec(decorTimeIn, refFreqIn+1)); %#ok - f unused
  end
end

% fill in channels in transform domain
hTrans = zeros(nR, nT, nTimeSamp, nFreqSamp);
for sampFreqIn = 1:nFreqSamp
  for sampTimeIn = 1:nTimeSamp
    
    refTimeIn = floor((sampTimeIn-1)/overSamp) + 1;
    frac      = mod(sampTimeIn-1, overSamp) / overSamp;
    
    hTrans(:, :, sampTimeIn, sampFreqIn) = ...
        evolveH(frac, ...
                hFreqRefs(refTimeIn, sampFreqIn), ...
                hFreqRefs(refTimeIn+1, sampFreqIn));
  end
end


% Transform to delay-doppler domain ---------------------------
[m1, m2, lenHTimeTrans, lenHFreqTrans] = size(hTrans); %#ok  - m1, m2 unused

hTensor = zeros(nR, nT, lenHTimeTrans, lenHFreqTrans);
if lenHTimeTrans == 1
  for rxIn = 1:nR
    for txIn = 1:nT
      hFreqTemp = reshape(hTrans(rxIn, txIn, :, :), lenHTimeTrans, lenHFreqTrans);
      hTemp     = fftshift(fft2(hFreqTemp));
      
      reShHTemp = reshape(hTemp, 1, 1, lenHTimeTrans, lenHFreqTrans);

      hTensor(rxIn, txIn, 1, :) = reShHTemp;
    end
  end
else
  for rxIn = 1:nR
    for txIn = 1:nT
      hFreqTemp = reshape(hTrans(rxIn, txIn, :, :), lenHTimeTrans, lenHFreqTrans);
      hTemp     = fftshift(fft2(hFreqTemp));
      
      reShHTemp = reshape(hTemp, 1, 1, lenHTimeTrans, lenHFreqTrans);

      hTensor(rxIn, txIn, :, :) = reShHTemp;
    end
  end
end

% Build nRx x .... version ------------------------------------
nDopSamp   = nTimeSamp;
nDelaySamp = nFreqSamp;
% h          = [];
% for dopIn = 1:nDopSamp
%   for delayIn = 1:nDelaySamp
%     h = [h hTensor(:, :, dopIn, delayIn) ];
%   end
% end
h = permute(hTensor, [1,2,4,3]);
h = h(:,:);


% correct normalization ---------------------------------------
fakeH          = complex(randn(nR, nT), randn(nR, nT)) / sqrt(2);
fakeHpow       = abs(trace(fakeH*fakeH'));
hNorm          = sqrt(fakeHpow/abs(trace(h*h')));
hCorNorm       = hNorm * h';
hTensorCorNorm = hNorm * hTensor;



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


