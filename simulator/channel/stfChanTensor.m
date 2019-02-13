function [hCorNorm, nDelaySamp, nDopSamp, hTensorCorNorm, fakeHpow] ...
    = stfChanTensor(alpha, nR, nT, ...
                    delaySpread, sampPeriod, overSamp, ...
                    dopplerSpread, blockPeriod, overDopSamp)

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


