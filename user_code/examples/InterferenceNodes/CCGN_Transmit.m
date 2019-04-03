function [nodeobj,sig] = CCGN_Transmit(nodeobj,modname,blockLen)

% Function user/CCGN_Transmit.m:
% Interference transmitter.  Complex Colored Gaussian Noise (CCGN).
%
% USAGE: [nodeobj,sig] = CCGN_Transmit(nodeobj,modname,blockLen)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object
%  modname    (string) The name of the module that has activated this
%              callback function
%  blockLen   (int) The block length of the analog signal expected
%              by the arbitrator
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of the node object
%  sig        (NxblockLen) Analog baseband signal for N channels
%
%

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

% Load user parameters
p = GetUserParams(nodeobj);
fs = GetModFs(nodeobj,modname);  % Simulation sample rate
fn = fs/2; % Nyquist frequency

% Design a filter using Parks-McClellan method
C = firpmord([-1/10,1/10]*fn+fn*1/6,[1 0],[.01,.005],fs,'cell');
B = firpm(C{:}) ;

% Make some noise data
sig = complex(randn(1,p.blockLen + length(B) - 1), randn(1,p.blockLen + length(B) - 1))/sqrt(2);

% Color the noise
sig = filter(B,1,sig) ;
sig = sig(length(B):end) ;

% Get the file power (unitless)
filePow = norm(B)^2;

% Set the transmitted signal power
sig = sqrt(p.power/filePow)*sig;

% Increment counter
p.transmittedBlocks = p.transmittedBlocks+1;

% Save user params
nodeobj = SetUserParams(nodeobj,p);


% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


