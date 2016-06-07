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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
dnParams.infoSourceFilename = './MIMONodes/testdata_long.dat';
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


