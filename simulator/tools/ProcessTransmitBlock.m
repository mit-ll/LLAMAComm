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
    if abs(ft - fr) < fs/100
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


