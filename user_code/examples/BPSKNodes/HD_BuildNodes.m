function hdNodes = HD_BuildNodes

% Function HD_BuildNodes.m:
% Example function/script for building example half-duplex nodes with
% common transmit/receive modules and user parameters.
%
% USAGE: hdNodes = BuildUserNodes
%
% Input arguments:
%  -none-
%
% Output arguments:
%  hdNodes  (1xN Node obj array) Newly-created user nodes
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


% Define transmit/recieve modules

hd_tx_mod_params.name = 'hd_tx';
hd_tx_mod_params.callbackFcn = @BPSK_Transmit;
hd_tx_mod_params.fc = 98.5e6;
hd_tx_mod_params.type = 'transmitter';
hd_tx_mod_params.loError = 0;
hd_tx_mod_params.antType = {'dipole_halfWavelength'};
hd_tx_mod_params.antPosition = [0 0 0];
hd_tx_mod_params.antPolarization = {'v'};
hd_tx_mod_params.antAzimuth = [0];
hd_tx_mod_params.antElevation = [0];
hd_tx_mod_params.exteriorWallMaterial = 'none';
hd_tx_mod_params.distToExteriorWall = [0];
hd_tx_mod_params.exteriorBldgAngle = [0];
hd_tx_mod_params.numInteriorWalls = [0];

hd_rx_mod_params.name = 'hd_rx';
hd_rx_mod_params.callbackFcn = @BPSK_Receive;
hd_rx_mod_params.fc = 98.5e6;
hd_rx_mod_params.type = 'receiver';
hd_rx_mod_params.loError = 0;
hd_rx_mod_params.antType = {'dipole_halfWavelength'};
hd_rx_mod_params.antPosition = [0 0 0];
hd_rx_mod_params.antPolarization = {'v'};
hd_rx_mod_params.antAzimuth = [0];
hd_rx_mod_params.antElevation = [0];
hd_rx_mod_params.exteriorWallMaterial = 'none';
hd_rx_mod_params.distToExteriorWall = [0];
hd_rx_mod_params.exteriorBldgAngle = [0];
hd_rx_mod_params.numInteriorWalls = [0];
hd_rx_mod_params.noiseFigure = 6; % (dB) noise figure of receiver

hd_tx_mod = module(hd_tx_mod_params);
hd_rx_mod = module(hd_rx_mod_params);


% Define nodes

userA_node_params.name = 'HD_UserA';
userA_node_params.location = [0 20 3];
userA_node_params.velocity = [0 0 0];
userA_node_params.controllerFcn = @HD_UserA_Controller;
userA_node_params.modules = [hd_tx_mod hd_rx_mod];

userB_node_params.name = 'HD_UserB';
userB_node_params.location = [100 0 2];
userB_node_params.velocity = [0 0 0];
userB_node_params.controllerFcn = @HD_UserB_Controller;
userB_node_params.modules = [hd_tx_mod hd_rx_mod];

userA_node = node(userA_node_params);
userB_node = node(userB_node_params);


% Set user parameters

userParams.power = 10; % (Watts)
userParams.dataLen = 800;
userParams.trainingLen = 200;
userParams.nOversamp = 2;
userParams.bitLen = userParams.dataLen+userParams.trainingLen;
userParams.blockLen = userParams.nOversamp*userParams.bitLen;

userParams.trainingSeq = rand(1,userParams.trainingLen)>.5;

userParams.nBlocksToSim = 15;
userParams.receivedBlocks = 0;
userParams.transmittedBlocks = 0;

userParams.txBits = zeros(userParams.nBlocksToSim,...
                          userParams.bitLen,'uint8');
userParams.rxBits = zeros(userParams.nBlocksToSim,...
                          userParams.bitLen,'uint8');

userParams.equalizerLen = 21;
userParams.equalizerDelay = 10;

userA_node = SetUserParams(userA_node,userParams);
userB_node = SetUserParams(userB_node,userParams);


% Put user nodes into array
hdNodes = [userA_node userB_node];





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


