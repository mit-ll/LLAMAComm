function LLMimoNodes = LLMimo_BuildNodes(range, envType)

% Function LLMimo_BuildNodes.m:
% Example function/script for building user nodes with common
% transmit/receive modules and user parameters.
%
% USAGE: LLMimoNodes = LLMimo_BuildNodes
%
% Input arguments:
%  range        (string) range is 'short', 'short-medium', 'medium', or 'long'
%  envType      (string) Environment type: 'rural', 'suburban', or 'urban'
%
% Output arguments:
%  LLMimoNodes  (1xN Node obj array) Newly-created user nodes
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

% Define transmit/receive modules

tx_mod_params.name = 'LLmimo_tx';
tx_mod_params.callbackFcn = @LLMimo_Transmit;
tx_mod_params.fc = 850e6;
tx_mod_params.type = 'transmitter';
tx_mod_params.loError = 0;
tx_mod_params.antType = {'dipole_halfWavelength'};
tx_mod_params.antPosition = [0 -5 0;
                             0 -4 0;
                             0 -3 0;
                             0 -2 0;
                             0 -1 0;
                             0 0 0;
                             0 1 0;
                             0 2 0;
                             0 3 0;
                             0 4 0]*3e8/tx_mod_params.fc;
tx_mod_params.antPolarization = {'v'};
tx_mod_params.antAzimuth = [0];
tx_mod_params.antElevation = [0];
tx_mod_params.exteriorWallMaterial = 'none';
tx_mod_params.distToExteriorWall = [0];
tx_mod_params.exteriorBldgAngle = [0];
tx_mod_params.numInteriorWalls = [0];


rx_mod_params.name = 'LLmimo_rx';
rx_mod_params.callbackFcn = @LLMimo_Receive;
rx_mod_params.TDCallbackFcn = @LLMimo_Rx_TDCallback;
rx_mod_params.fc = 850e6;
rx_mod_params.type = 'receiver';
rx_mod_params.loError = 0;
rx_mod_params.noiseFigure = 6; % (dB) noise figure of receiver
rx_mod_params.antType = {'dipole_halfWavelength'};
rx_mod_params.antPosition = [0 -4 0;
                             0 -2 0;
                             0 0 0;
                             0 2 0]*3e8/rx_mod_params.fc;
rx_mod_params.antPolarization = {'v'};
rx_mod_params.antAzimuth = [0];
rx_mod_params.antElevation = [0];
rx_mod_params.exteriorWallMaterial = 'none';
rx_mod_params.distToExteriorWall = [0];
rx_mod_params.exteriorBldgAngle = [0];
rx_mod_params.numInteriorWalls = [0];


tx_mod = module(tx_mod_params);
rx_mod = module(rx_mod_params);

% Create genie modules
tx_gen.name = 'genie_tx';
tx_gen.type = 'transmitter';

rx_gen.name = 'genie_rx';
rx_gen.type = 'receiver';

gen_tx_mod = module(tx_gen,1);
gen_rx_mod = module(rx_gen,1);


% Define nodes

DN_node_params.name = 'DN';
switch lower(range)
    case 'short'
        DN_node_params.location = [1.0e3 0 3];
    case 'short-medium'
        DN_node_params.location = [2.5e3 0 3];
    case 'medium'
        DN_node_params.location = [5.0e3 0 3];
    case 'long'
        DN_node_params.location = [1.0e4 0 3];
    otherwise
        error('Incorrect range case')
end
DN_node_params.velocity = [0 0 0];
DN_node_params.controllerFcn = @LLMimo_DN_Controller;
DN_node_params.modules = [tx_mod gen_rx_mod];

AN_node_params.name = 'AN';
switch lower(envType)
    case 'rural'
        AN_node_params.location = [0 0 100];
    case 'suburban'
        AN_node_params.location = [0 0 30];
    case 'urban'
        AN_node_params.location = [0 0 30];
    otherwise
        error('Incorrect environment type!')
end
AN_node_params.velocity = [0 0 0];
AN_node_params.controllerFcn = @LLMimo_AN_Controller;
AN_node_params.modules = [rx_mod gen_tx_mod];

DN_node = node(DN_node_params);
AN_node = node(AN_node_params);


% Define shared parameters (packet definition)
sharedParams.noiseLen = 100;
sharedParams.hTrainingLen = 100;
sharedParams.hTrainingSeq = rand(GetNumAnts(tx_mod),...
    sharedParams.hTrainingLen)>.5;
sharedParams.trainingLen = 100;
sharedParams.trainingSeq = rand(1,sharedParams.trainingLen)>.5;
sharedParams.infoLen = 512;
sharedParams.spreadRatio = 5;
sharedParams.nOversamp = 3;
sharedParams.blockLen = sharedParams.nOversamp*...
    (sharedParams.noiseLen+sharedParams.hTrainingLen+...
     sharedParams.trainingLen+sharedParams.spreadRatio...
     *sharedParams.infoLen);
sharedParams.nBlocksToSim = 8;

% DN-specific (Transmitter) parameters
dnParams.transmittedBlocks = 0;
dnParams.txPower = 1; % (Watts)
dnParams.targDomAtten = 2;
dnParams.infoSourceFilename = './examples/MIMONodes/testdata_long.dat';
dnParams.infoSourceFID = [];
dnParams.infoBits = [];
dnParams.txBitsFilename = '';
dnParams.txBitsFID = [];
dnParams.getFromRx = [];

% AN-specific (Receiver) parameters
anParams.receivedBlocks = 0;
anParams.epsilon = 10^-5;
anParams.lagRange = [-50:5];
anParams.rxBitsFilename = '';
anParams.rxBitsFID = [];
anParams.passToTx = [];

% Save parameters within nodes
dnParams = StructMerge(dnParams,sharedParams);
DN_node = SetUserParams(DN_node,dnParams);

anParams = StructMerge(anParams,sharedParams);
AN_node = SetUserParams(AN_node,anParams);


% Put user nodes into array
LLMimoNodes = [DN_node AN_node];





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


