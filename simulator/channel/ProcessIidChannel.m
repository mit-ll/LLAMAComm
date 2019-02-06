function [rxsig] = ProcessIidChannel(startSamp, channel, source)

% Function simulator/channel/ProcessIidChannel.m:
% Performs the channel propagation and signal processing according to
% the iid channel model.  It is called by @link/PropagateToReceiver.m.
%
% USAGE: [rxsig] = ProcessIidchannel(startSamp, channel, source)
%
% Input arguments:
%  startSamp (int) Channel sample number start
%  channel   (struct) Struct containing channel definition
%  source    (nT x blockLength + nDelay complex)  Transmitted signal
%
% Output argument:
%  rxsig     (nR x N complex) Analog signal received by module.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify the number of receivers and transmitters
[nR, nT] = size(channel.powerProfile);

% Specify the number of output samples per Rx antenna
nS = size(source, 2) - channel.longestLag;

if nS < 1
    error('The source length: %d is less than the longest channel length: %d', ...
          num2str(size(source, 2)), ...
          num2str(channel.longestLag+1));
end

chanstates = channel.chanstates;
riceKlin   = 10^(0.1*channel.riceKdB);

if isinf(riceKlin)
    inds = (1:nS) + channel.longestLag - channel.powerProfile(1, 1).riceLag;
    rxsig = channel.riceMatrix*source(:, inds);
else
    % transpose the source so multiplication works out
    source = source.';


    nS_ones = ones(1, nS);
    longestLag = channel.longestLag;
    powerProf = channel.powerProfile;

    rxtxDOF = nR*nT;
    allSigs = zeros(rxtxDOF, nS);
    %for rxtxLoop = 1:rxtxDOF
    parfor rxtxLoop = 1:rxtxDOF

        chanstate = chanstates{rxtxLoop};
        pprof = powerProf(rxtxLoop);
        % rLoop = 1+ mod(rxtxLoop-1, nR);
        tLoop = 1+floor((rxtxLoop-1)/nR);
        
        % Generate time-varying channel
        H = jakes4(startSamp, nS, chanstate);
        
        % Apply power profile
        %pows = pprof.pows /sqrt(riceKlin + 1);
        pows = pprof.pows /(riceKlin + 1);

        % H = H.*repmat(sqrt(pows(:)), 1, nS);
        % H = bsxfun(@times, H, sqrt(pows(:)));
        H = H.*(sqrt(pows(:))*nS_ones); 
        
        % Get ready for convolution
        H = H.';
        
        allSigs(rxtxLoop, :) = TVConv(H, pprof.lags, source(:, tLoop), longestLag); %#ok source not sliced
    end % END rLoop

    rxsig = reshape(sum(reshape(allSigs, [nR, nT, nS]), 2), [nR, nS]);
    allSigs = []; %#ok - allSigs no longer needed 

    % Do the Rice tap
    inds = (1:nS) + channel.longestLag - channel.powerProfile(1, 1).riceLag;
    source = source.';  % Flip the source back
    riceMat = sqrt(riceKlin/(riceKlin + 1))*channel.riceMatrix;
    rxsig = rxsig + riceMat*source(:, inds);
end

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


