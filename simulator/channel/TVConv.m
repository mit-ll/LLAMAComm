function output = TVConv(H, lags, src, longestLag)
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

persistent calledBefore

if isempty(calledBefore)
  fprintf(1, ['\n   WARNING Missing MEX function: TVConv.%s',  ...
              '.\n   You can create the mex function by changing', ...
              ' the\n   working directory to', ...                    
              ' /simulator/channel/\n   and typing "mex', ...         
              ' TVConv.c"\n\n'], mexext);                             
  calledBefore = true;                                                
end                                                                   

frmLen = size(H, 1); % obtain the number of samples
%%numLags = size(H, 2); % obtain the number of lags
multAddIndices = longestLag - lags + 1; % compute indices in signal buffer corresponding to non-zero channel filter tap values
Hf = flipud(H); % convolutional flip of filter taps

innerProduct = zeros(1, frmLen);

for n = 1:min(frmLen, longestLag) % loop through the sample index
    firstIndx = 1;
    sigBuffer = src(firstIndx:n).';
    
    sigFilt = Hf(n, :); % obtain the current channel taps
    culledIndices = multAddIndices <= length(sigBuffer); % obtain the indices over which the multiply-add is to be performed
    innerProduct(n) = sum(sigFilt(culledIndices).*sigBuffer(multAddIndices(culledIndices))); % perform the multiply-add   
end
for n = longestLag+1:frmLen % loop through the sample index
    firstIndx = n - longestLag;    
    sigBuffer = src(firstIndx:n).';
    
    sigFilt = Hf(n, :); % obtain the current channel taps
    culledIndices = multAddIndices <= length(sigBuffer); % obtain the indices over which the multiply-add is to be performed
    innerProduct(n) = sum(sigFilt(culledIndices).*sigBuffer(multAddIndices(culledIndices))); % perform the multiply-add   
end


% obtain the "valid" convolution output by taking off the first longestLag samples 
output = zeros(size(innerProduct));
temp = innerProduct(longestLag+1:end);
output(1:length(temp)) = temp;
