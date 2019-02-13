function [nodeobj,sig] = CWGN_Transmit(nodeobj,modname,blockLen)

% Function user/CWGN_Transmit.m:
% Interference transmitter.  Just white noise for now.
%
% USAGE: [nodeobj,sig] = CWGN_Transmit(nodeobj,modname,blockLen)
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

% Load user parameters
p = GetUserParams(nodeobj);

% Make some noise data
filePow = 1; % Unitless file power
sig = sqrt(filePow/2)*complex(randn(1,p.blockLen), randn(1,p.blockLen));

% Set the transmitted signal power
sig = sqrt(p.power/filePow)*sig;

% Increment counter
p.transmittedBlocks = p.transmittedBlocks+1;

% Save user params
nodeobj = SetUserParams(nodeobj,p);


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


