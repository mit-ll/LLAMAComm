function [source] = ProcessTransmitBlock(source, blockStart, blockLen, ft, fr, fs, taps)

% Function tools/ProcessTransmitBlock.m:
% Performs the signal processing on the analog transmit data necessary 
% to inband signal seen by the link channel.  
%
% USAGE: [source] = ...
%        ProcessTransmitBlock(source, blockStart, blockLen, ft, fr, fs, taps)
%
% Input arguments:
%  source       (nTx x nSamps complex) Transmit data
%  blockStart   (int) Start sample
%  blockLen     (int) Length of the source block
%  ft           (double) Transmit block center frequency
%  fr           (double) Receive module center frequency
%  fs           (double) Simulator sampling rate
%  taps         (1xN) Anti-alias filter taps used by filtfilt.m
%
% Output argument:
%  source    (nTx x nSamps complex) Analog signal seen by receive link.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of transmit antennas
nTx = size(source, 1);

% Make sure there is frequency overlap
if abs(ft - fr) > fs
    error('Distance between tx and rx center freqs is greater than fs!')
end

% Oversampling Factor
nOver = 3;

if ft == fr
    % do nothing because the signals are perfectly overlapping
    % linkobj.freqOverlapMethod = 'none: Tx and Rx have same fc';
else
% If the difference between ft and fr is within 1% of the the sampling rate, 
% then don't do interpolation and decimation
    if abs(ft - fr) < fs/100;
        % Apply frequency shifting
        source = source...
            .*repmat(exp(1j*2*pi*(ft-fr)...
                         *(blockStart:blockStart + blockLen-1)/fs), ...
                     nTx, 1);
    else % Interpolate, modulate, and decimate the transmit block
        source = resample(source.', nOver, 1).';
        source = source...
            .*repmat(exp(1j*2*pi*(ft-fr)...
                         *(nOver*blockStart:nOver*blockStart + nOver*blockLen-1)/(nOver*fs)), ...
                     nTx, 1);
        source = resample(source.', 1, nOver).';
        % linkobj.freqOverlapMethod = 'modulate and filter';
    end % End if abs(ft-fr) < fn/100;
    
    % Clean up with anti-alias filter
    source = filtfilt(taps, 1, source.').';

end % End if ft == fr

% Copyright (c) 2006-2012, Massachusetts Institute of Technology All rights
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


