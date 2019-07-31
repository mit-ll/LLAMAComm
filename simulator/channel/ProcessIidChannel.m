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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

% Specify the number of receivers and transmitters
[nR, nT] = size(channel.powerProfile);

% If applicable, compute Rx spatial correlation matrix square-root
if(nR > 1 && ~isempty(channel.rxCorrMat))
    Rr = channel.rxCorrMat;
    flagCorrRx = true;
else
    Rr = 1;
    flagCorrRx = false;
end

% If applicable, compute Tx spatial correlation matrix square-root
if(nT > 1 && ~isempty(channel.txCorrMat))
    Rt = channel.txCorrMat;
    flagCorrTx = true;
else
    Rt = 1;
    flagCorrTx = false;
end

if(flagCorrTx || flagCorrRx)
    Rf = kron(Rt.', Rr);
end

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

    % obtain the first antenna-pair power profile for initialization
    pprofInit = powerProf(1, 1);
    Hagg = zeros(rxtxDOF, length(pprofInit.lags)*nS);

    if(flagCorrTx || flagCorrRx)

        numLags = length(pprofInit.lags);
        for rxtxLoop = 1:rxtxDOF

            chanstateC = chanstates{rxtxLoop};

            % Get transmitter and receiver out of the combined rxtx indexing
            rxIndx = 1 + mod(rxtxLoop-1, nR);
            txIndx = 1 + floor((rxtxLoop-1)/nR);

            % Generate time-varying channel
            Hj = jakes4(startSamp, nS, chanstateC);

            % Aggregate Jakes processes in MIMO-Jakes matrix
            Hagg(rxtxLoop, :) = Hj(:).';
        end

        Hcorr = sqrtm(Rf)*Hagg; % correlate the Jakes processes

    end

    %parfor rxtxLoop = 1:rxtxDOF
    for rxtxLoop = 1:rxtxDOF
        rxIndx = 1 + mod(rxtxLoop-1, nR);
        txIndx = 1 + floor((rxtxLoop-1)/nR);

        % Generate time-varying channel
        if(flagCorrTx || flagCorrRx) % if spatial-correlation is on

            H = reshape(Hcorr(rxtxLoop, :), numLags, nS);
            pprof = pprofInit;
        else
            chanstate = chanstates{rxtxLoop};
            pprof = powerProf(rxtxLoop);
            % rLoop = 1+ mod(rxtxLoop-1, nR);

            H = jakes4(startSamp, nS, chanstate);
        end

        tLoop = 1+floor((rxtxLoop-1)/nR);
        % Apply power profile
        %pows = pprof.pows /sqrt(riceKlin + 1);
        pows = pprof.pows /(riceKlin + 1);

        % H = H.*repmat(sqrt(pows(:)), 1, nS);
        % H = bsxfun(@times, H, sqrt(pows(:)));
        H = H.*(sqrt(pows(:))*nS_ones);

        % Get ready for convolution
        H = H.';

        allSigs(rxtxLoop, :) = TVConv(H, pprof.lags, source(:, tLoop), longestLag);
    end % END rLoop

    rxsig = reshape(sum(reshape(allSigs, [nR, nT, nS]), 2), [nR, nS]);
    allSigs = []; %#ok - allSigs no longer needed

    % Do the Rice tap
    inds = (1:nS) + channel.longestLag - channel.powerProfile(1, 1).riceLag;
    source = source.';  % Flip the source back
    riceMat = sqrt(riceKlin/(riceKlin + 1))*channel.riceMatrix;
    rxsig = rxsig + riceMat*source(:, inds);
end

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


