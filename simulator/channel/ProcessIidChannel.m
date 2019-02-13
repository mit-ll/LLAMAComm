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


