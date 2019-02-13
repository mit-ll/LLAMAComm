function [h,  nSamp,  hTensor] = stChanTensor(alpha, nR, nT,  ...
                                              delaySpread, sampPeriod, overSamp)

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


