function LLMimo_Rx_TDCallback(src, evt, filename, fPointer, ...
    fignum, nodename, modname, fc, fs, p)

% Function LLMimo_Rx_TDCallback.m:
% Callback function for rectangles drawn in the timing diagram figure.
% Clicking on one of the rectangles will cause this function to be called.
%
% This is a modified version of td/DefaultTDCallback.m.  It plots
% the spectrum of the received signal and a scatter plot
%
% USAGE:  See simulator/td/DefaultTDCallback.m
%
% Input arguments:
%  src       (obj handle) Handle to object that triggered callback
%  evt       (not used, but required)
%  filename  (string) Path and filename to .cog file
%  fPointer  (int) File offset.  Points to start of a signal block
%  fignum    (int) Figure number of plot to be made
%  nodename  (string) Node name for plot title
%  modname   (string) Module name for plot title
%  fc        (scalar) Center frequency of module
%  fs        (scalar) Sampling rate
%  p         (struct) User parameters at the time this callback was
%             set up.  The callback is set up by 
%             @module/UpdateTimingDiagram.m immediately after finishing
%             one of the user-defined module callback functions (the
%             transmit or receive function)
%
% Output arguments:
%  -none-
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Open new figure
fh = figure(fignum);
clf(fh);

% Open signal file for reading
fid = OpenSigFile(filename);

% Read signal block 
sig = ReadSigBlock(fid, fPointer);

% Because this function only has access to the analog signal stored
% on disk, the block will have to be reprocessed using code
% pasted in from LLMimo_Receive.m

% Subsample signal
sig = resample(sig.', 1, p.nOversamp).';

% STAP receiver
trainData = sig(:, (1:p.trainingLen)+p.noiseLen+p.hTrainingLen);
trainRef  = 1-2*p.trainingSeq;
stTrainData = Stackzs(trainData, p.lagRange) ;
rST         = stTrainData*stTrainData' ;

wUn = inv(rST+p.epsilon*trace(rST)*eye(length(rST))) ...
    *stTrainData*trainRef' ;
w   = wUn / norm(wUn) ;
rxInfoData = sig(:, (1+p.noiseLen + p.trainingLen + p.hTrainingLen):end);
rxST = Stackzs(rxInfoData, p.lagRange) ;

y = w'*rxST ;


% Plot receiver output
ah1 = subplot(1, 2, 1);
plot(real(y), imag(y), '.');
axis equal;
xlabel('Re(y)');
ylabel('Im(y)');
th = title(sprintf('%s:%s - Receiver Output', nodename, modname));
set(th, 'Interpreter', 'none');

% Plot spectrum
ah2 = subplot(1, 2, 2);
Ps = pwelch(y, [], [], [], fs/p.nOversamp, 'twosided');
f = ShiftedFreqScale(length(Ps), fs/p.nOversamp) + fc;
sh = plot(f/1e6, db10(fftshift(Ps)));
xlabel('MHz')
ylabel('Pxx  Watts / Hz (dB)');
grid on
set(ah2, 'XLimMode', 'manual');
set(ah2, 'Xlim', [f(1) f(end)]/1e6);
title(sprintf('fc=%.3f MHz', fc/1e6));





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


