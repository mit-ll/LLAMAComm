function [h,weightVec] = ...
    stfChan(alpha,n,delaySpread,nDelay,freqSpread,nFreq,...
    sampRatioT,sampRatioF,firstV)
%
%  This function produces random space-time-frequency channel matrices 
%  with a give spatial correlation.  
%
% Outputs
%  h        - stf channel matrix with the dimension of 
%           nRx by (nTx*nReDelay*nReFreq) where
%               nReDelay = ceil(nDelay*sampRatioT(1)/sampRatioT(2)) ;
%               nReFreq  = ceil(nFreq*sampRatioF(1)/sampRatioF(2)) ;
%
%  weightVec - weighting vector applied to give delay and frequency 
%           dependent fall off
% 
% 
% Inputs
%   alpha   - correlation parameter 0 >= alpha >= 1, 
%           where 0 indicates a rank 1 channel, and 1 indicates a 
%           gaussian channel.  If alpha is a scalar then the channel
%           correlation is symmetric. Otherwise, two entries indicate
%           the receiver and transmitter alpha respectively.
%           
%   n       - number of antennas.  If n is a scalar then the channel
%           channel matrix is symmetric.  Otherwise, two entries 
%           indicate the number of receiver and transmitter channels
%           respectively.
%
%   delaySpread - a measure of delays spread in units of critical
%           sample period (not actual sample period)
%
%   nDelay  - number of delay taps
%
%   freqSpread - a measure of the doppler frequency spread in units of
%           resolvable doppler (1 / coherent processing interval), 
%           matched to stfData
%                       
%   nFreq   - number of frequency taps
%
%   sampRatioT - array [p q] which is used by "resample" to allow
%           for use with temporally over-sampled data.  If q is
%           absent, it is assumed to be 1.
%
%   sampRatioF - array [p q] which is used by "resample" to allow
%           for use with data frequency shifts of less then that
%           determined by the coherent processing interval.  If q is
%           absent, it is assumed to be 1.
%
%   firstV  - is an optional parameter that is used to specify the
%           first (dominant) column of the unitary matrix associated 
%           with the channel

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

if nargin < 7
    sampRatioT = [1 1] ;
elseif length(sampRatioT) < 2
    sampRatioT(2) = 1 ;
end

if nargin < 8
    sampRatioF = [1 1] ;
elseif length(sampRatioF) < 2
    sampRatioF(2) = 1 ;
end

if nargin < 9
  firstV = complex( randn(n(1),1), randn(n(1),1) ) / sqrt(2) ;
end

if delaySpread == 0
    delayVec = [1 zeros(1,nDelay-1)] ;
else
    delayVec  = exp(-(0:(nDelay-1)) / (2 * (delaySpread))) ;
end

if freqSpread == 0
    freqVec = zeros(1,nFreq) ;
    freqVec(ceil(nFreq/2)) = 1 ;
else
    maxFreqIn = (nFreq-1)/2 ;
    freqVec   = exp(-((-maxFreqIn:maxFreqIn).^2 / (4 * freqSpread^2))) ;
end

weightingMatrixUn = delayVec.' * freqVec ;
weightingMatrix   = weightingMatrixUn / norm(weightingMatrixUn(:)) ;

weightVec = weightingMatrix(:) ;


% h   = [] ;
% wIn = 0 ;
% for freqIn = 1:nFreq
%     wIn = wIn + 1 ;
%     if freqIn == floor((nFreq-1)/2)
%         h = [h weightVec(wIn) * correlatedChannelMatrix(alpha,n,firstV) ] ; 
%     else
%         h = [h weightVec(wIn) * correlatedChannelMatrix(alpha,n) ] ; 
%     end
%     
%     for delayIn = 2:nDelay
%         wIn = wIn + 1 ;
%         h = [h weightVec(wIn) * correlatedChannelMatrix(alpha,n) ] ; 
%     end
% end
% 
        
hUnWTensor = zeros(n(1),n(2),nDelay,nFreq) ;
for delayIn = 1:nDelay
    corH0 = correlatedChannelMatrix(alpha,n,firstV) ;
    corH  = correlatedChannelMatrix(alpha,n) ;
    for freqIn = 1:nFreq
        if (delayIn == 1)
            hUnWTensor(:,:,delayIn,freqIn) = corH0 ;
        else
            hUnWTensor(:,:,delayIn,freqIn) = corH ;    
        end
    end
end

nReDelay = ceil(nDelay*sampRatioT(1)/sampRatioT(2)) ;
nReFreq  = ceil(nFreq*sampRatioF(1)/sampRatioF(2)) ;
hTensorResamp = zeros(n(1),n(2), nReDelay, nReFreq) ;

for rxIn = 1:n(1)
    for txIn = 1:n(2)
        m  = reshape(hUnWTensor(rxIn,txIn,:,:),nDelay,nFreq) ;
        mw = m .* weightingMatrix ;
        
        if nReDelay == nDelay
            mUpDelay = mw ;
        else
            mUpDelay = resample(mw,sampRatioT(1),sampRatioT(2)) ;
        end
        
        if nReFreq == nFreq
            mUp = mUpDelay ;
        else
            mUp      = resample(mUpDelay.',sampRatioF(1),sampRatioF(2)).' ;
        end
        
        hTensorResamp(rxIn,txIn,:,:) = mUp ;
    end
end

h = reshape(hTensorResamp,n(1),n(2)*nReDelay*nReFreq) ;




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


