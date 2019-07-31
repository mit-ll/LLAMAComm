function [linkobj, rxsig] = PropagateToReceiver(linkobj, modTx, modRx, histIdx); %#ok - histIndx unused

% Function @link/PropagateToReceiver.m:
% Performs the channel propagation and signal processing on the
% analog transmit data necessary to produce the analog signal seen
% by the receiving module in the link.  It is called by
% @environment/DoPropagation.m for each link.
%
% USAGE: [linkobj, rxsig] = PropagateToReceiver(linkObj, source)
%
% Input arguments:
%  linkObj  (link obj) link object
%  source   (nT x blockLength complex)  In-band analog transmitted signal
%
% Output argument:
%  rxsig    (MxN complex) Analog signal received by module.
%            M channels x N samples.

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

global DisplayLLAMACommWarnings;

debug = ~true;

% get the receiver module request
req = GetRequest(modRx);

% Get starting sample and blockLength of receive block
startRx = req.blockStart;
blockLengthRx = req.blockLength;

% Get the number of transmit and receive antennas
nT = GetNumAnts(modTx);
%nR = GetNumAnts(modRx);

% Get center frequency of the requesting receive module
fr = req.fc;

switch lower(linkobj.channel.chanType)
  case {'wssus-wideband'}
    antSepSamps = linkobj.channel.nodeAntSepSamps;
  otherwise
    antSepSamps = 0; % Zero unless otherwise modeled
end

% Get parameters from link object
nPropDelaySamp  = linkobj.channel.nPropDelaySamp;
sampRate        = GetFs(modRx);

%---------------------------------------------------------------
% Build contiguous data from file.  The transmit blocks are appropriately
%  modulated and filtered.
nPropDelaySampFix  = fix(nPropDelaySamp);  % Get the integer part
nPropDelaySampFrac = nPropDelaySamp - nPropDelaySampFix;   % Get the decimal part

if nPropDelaySampFrac == 0
    % No fractional delay filter applied
    fracDelayFilter = [];
else
    % Get block length including fractional-delay filter length
    fracDelayFilter = linkobj.channel.fracDelayFilter;
end
delayFiltLen = max(1, length(fracDelayFilter));

switch lower(linkobj.channel.chanType)
  case {'stfcs', 'wideband_awgn'}
    nDelay  = linkobj.channel.nDelaySamp;

  case {'wssus', 'los_awgn', 'env_awgn'}
    nDelay  = linkobj.channel.longestLag + 1;

  case {'wssus-wideband'}
    nDelay  = linkobj.channel.longestLag + 1; % Delay spread
    delayFiltLen = linkobj.channel.nDelayFiltLen;
end

startRxChan = startRx - (nDelay-1) - nPropDelaySampFix - ((delayFiltLen - 1)/2) - antSepSamps;
blockLengthRxChan = blockLengthRx + ...
    (nDelay - 1) + ...
    (delayFiltLen - 1) + ...
    antSepSamps;

fs = GetFs(modTx);
taps = linkobj.antialiasTaps;
[result, ft] = AllSameTxFc(modTx, startRxChan, blockLengthRxChan, fr); % If tx blocks have same fc
if isempty(result)
    source = [];  % source is empty if all wait blocks or all out of band

elseif result
    [source, blockLen] = ReadContiguousData(modTx, startRxChan, blockLengthRxChan, fr);
    %ft = GetFc(modTx);

    % Check for sufficient length
    if (size(source, 2) < length(taps)) && ~isempty(source)

        % Build Link ID
        linkID = sprintf('''%s:%s'' -> ''%s:%s:%.2f MHz''', ...
                         linkobj.fromID{1}, linkobj.fromID{2}, ...
                         linkobj.toID{1}, linkobj.toID{2}, linkobj.toID{3}/1e6);

        % Display a warning
        if DisplayLLAMACommWarnings
            disp(['Warning in link: ', linkID, '. Receive blocklength (', ...
                  num2str(blockLen), ...
                  ') is less than number of filtfilt taps (', num2str(length(taps)), ')'])
        end
    end

    % Display a warning if fr ~= ft
    if DisplayLLAMACommWarnings
        if fr ~= ft

            % Build Link ID
            linkID = sprintf('''%s:%s:%.2f MHz'' -> ''%s:%s:%.2f MHz''', ...
                             linkobj.fromID{1}, linkobj.fromID{2}, ft/1e6, ...
                             linkobj.toID{1}, linkobj.toID{2}, linkobj.toID{3}/1e6);

            msg1 =['Warning: The time edges of link ', linkID];
            msg2 = '         are mangled because the Tx and Rx modules have different center frequencies!';
            msg3 = '         See Section 3.2.2 in the documentation for more details.';
            fprintf('\n%s\n%s\n%s\n', msg1, msg2, msg3);
        end
    end

    % Modulate transmit signal based on receive module center frequency
    source = ProcessTransmitBlock(source, startRxChan, blockLengthRxChan, ft, fr, fs, taps);
else
    % Modulate each transmit block individually according to
    % their center frequencies and take each signal separately
    [source, blockLen] = BuildTransmitSignal(modTx, ...
                                             startRxChan, ...
                                             blockLengthRxChan, ...
                                             fr, ...
                                             taps, ...
                                             linkobj.fromID, ...
                                             linkobj.toID); %#ok blockLen unused
end

% Return empty if source is empty
if isempty(source)
    rxsig = [];
    return
end

% Perform partial-delay filtering if necessary
if ~isempty(fracDelayFilter) && (nPropDelaySampFrac ~= 0)
    out = zeros(nT, size(source, 2) + delayFiltLen - 1);
    for dLoop = 1:nT
        out(dLoop, :) = conv(source(dLoop, :), fracDelayFilter);
    end
    source = out(:, (3*delayFiltLen - 1)/2 + (0:blockLengthRx + nDelay - 2));
end

%---------------------------------------------------------------
% Apply the space-time-frequency channel tensor
%rxsig = linkobj.channel.chanTensor*source;

switch lower(linkobj.channel.chanType)

  case {'stfcs', 'wideband_awgn'}

    rxsig = ProcessSampledChannel(startRx, linkobj.channel, source);

  case 'wssus'

    rxsig = ProcessIidChannel(startRx, linkobj.channel, source);

  case 'wssus-wideband'

    % Check to see if there is a shortfall in the requested samples
    % This can happ
    if size(source, 2) < blockLengthRxChan
        nSampShortfall = blockLengthRxChan-size(source,2);

        % Sanity check. It makes sense to fix the sample shortfall iff
        % it consistent with being due to the fractional delay filtering.
        % Otherwise, there must be some other problem:
        if nSampShortfall < floor(delayFiltLen*0.5)
            source = [source, zeros(size(source,1), nSampShortfall)];
        else
            error('Excessive shortfall from number of requested samples, unable to continue');
        end
    end

    rxsig = ProcessIidWBChannel(startRx, linkobj.channel, source);

  case {'los_awgn', 'env_awgn'}

    rxsig = linkobj.channel.riceMatrix*source;

  otherwise
    error('Incorrect channel type: %s', chanType);

end % END switch over channel type

if debug
    fprintf(1, 'ProcessChannel:\n');
    fprintf(1, '    length(rxsig)     = %d\n', length(rxsig));
end

%---------------------------------------------------------------
% Apply the local oscillator frequency offsets
mTx = struct(modTx);
mRx = struct(modRx);
%freqOffset = (mTx.loError + mTx.loCorrection ...
%              - mRx.loError - mRx.loCorrection)*fr;
%
%if freqOffset > 0.01*sampRate
%  % Build Link ID
%  linkID = sprintf('''%s:%s:%.2f MHz'' -> ''%s:%s:%.2f MHz''', ...
%                   linkobj.fromID{1}, linkobj.fromID{2}, ft/1e6, ...
%                   linkobj.toID{1}, linkobj.toID{2}, linkobj.toID{3}/1e6);
%  error('The frequency offset %2.2f Hz in link %s\nis greater than 1%% of the sample rate %2.6f MHz\n', ...
%        freqOffset, linkID, sampRate/1e6);
%end
%
%if freqOffset ~= 0
%  modulation = exp(1i*2*pi*(freqOffset/fs)...
%                   *((0:size(rxsig, 2)-1) + startRx));
%  rxsig = repmat(modulation, size(rxsig, 1), 1).*rxsig;
%end
loOffset = (mTx.loError + mTx.loCorrection ...
            - mRx.loError - mRx.loCorrection)*fr;

if loOffset > 0.01*sampRate
    % Build Link ID
    linkID = sprintf('''%s:%s:%.2f MHz'' -> ''%s:%s:%.2f MHz''', ...
                     linkobj.fromID{1}, linkobj.fromID{2}, ft/1e6, ...
                     linkobj.toID{1}, linkobj.toID{2}, linkobj.toID{3}/1e6);

    error('The frequency offset %2.2f Hz in link %s\nis greater than 1%% of the sample rate %2.6f MHz\n', ...
          loOffset, linkID, sampRate/1e6);
end

% add in doppler offset on the link
if(linkobj.propParams.velocityShift ~= 0)
    c         = 2.998e8; % speed of light
    dopplerOffset = GetFc(modRx).*(linkobj.propParams.velocityShift./c);
else
    dopplerOffset = 0;
end
if loOffset ~= 0 || dopplerOffset ~= 0
    totalOffset = loOffset + dopplerOffset;
    modulation = exp(1i*2*pi*(totalOffset/fs)...
                     *((0:size(rxsig, 2)-1) + startRx));
    rxsig = repmat(modulation, size(rxsig, 1), 1).*rxsig;
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
