function fdNodes = FD_BuildNodes

% Function FD_BuildNodes.m:
% Example function/script for building full-duplex user nodes.
% This function reuses the transmit and receive functions from
% the BuildUserNode.m example.
%
% USAGE: fdNodes = FD_BuildNodes
%
% Input arguments:
%  -none-
%
% Output arguments:
%  fdNodes  (1xN Node obj array) Newly-created full-duplex user nodes
%

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


% Define transmit/recieve modules

fd1_tx_mod_params.name = 'fd1_tx';
fd1_tx_mod_params.callbackFcn = @BPSK_Transmit;
fd1_tx_mod_params.fc = 2495e6;
fd1_tx_mod_params.type = 'transmitter';
fd1_tx_mod_params.loError = 0;
fd1_tx_mod_params.antType = {'dipole_halfWavelength'};
fd1_tx_mod_params.antPosition = [0 0 0];
fd1_tx_mod_params.antPolarization = {'v'};
fd1_tx_mod_params.antAzimuth = [0];
fd1_tx_mod_params.antElevation = [0];
fd1_tx_mod_params.exteriorWallMaterial = 'none';
fd1_tx_mod_params.distToExteriorWall = [0];
fd1_tx_mod_params.exteriorBldgAngle = [0];
fd1_tx_mod_params.numInteriorWalls = [0];

fd1_rx_mod_params.name = 'fd1_rx';
fd1_rx_mod_params.callbackFcn = @BPSK_Receive;
fd1_rx_mod_params.fc = 2495e6;
fd1_rx_mod_params.type = 'receiver';
fd1_rx_mod_params.loError = 0;
fd1_rx_mod_params.noiseFigure = 6; % (dB) noise figure of receiver
fd1_rx_mod_params.antType = {'dipole_halfWavelength'};
fd1_rx_mod_params.antPosition = [0 0 0];
fd1_rx_mod_params.antPolarization = {'v'};
fd1_rx_mod_params.antAzimuth = [0];
fd1_rx_mod_params.antElevation = [0];
fd1_rx_mod_params.exteriorWallMaterial = 'none';
fd1_rx_mod_params.distToExteriorWall = [0];
fd1_rx_mod_params.exteriorBldgAngle = [0];
fd1_rx_mod_params.numInteriorWalls = [0];

fd2_tx_mod_params.name = 'fd2_tx';
fd2_tx_mod_params.callbackFcn = @BPSK_Transmit;
fd2_tx_mod_params.fc = 1500e6;
fd2_tx_mod_params.type = 'transmitter';
fd2_tx_mod_params.loError = 0;
fd2_tx_mod_params.antType = {'dipole_halfWavelength'};
fd2_tx_mod_params.antPosition = [0 0 0];
fd2_tx_mod_params.antPolarization = {'v'};
fd2_tx_mod_params.antAzimuth = [0];
fd2_tx_mod_params.antElevation = [0];
fd2_tx_mod_params.exteriorWallMaterial = 'none';
fd2_tx_mod_params.distToExteriorWall = [0];
fd2_tx_mod_params.exteriorBldgAngle = [0];
fd2_tx_mod_params.numInteriorWalls = [0];

fd2_rx_mod_params.name = 'fd2_rx';
fd2_rx_mod_params.callbackFcn = @BPSK_Receive;
fd2_rx_mod_params.fc = 1500e6;
fd2_rx_mod_params.type = 'receiver';
fd2_rx_mod_params.loError = 0;
fd2_rx_mod_params.noiseFigure = 6; % (dB) noise figure of receiver
fd2_rx_mod_params.antType = {'dipole_halfWavelength'};
fd2_rx_mod_params.antPosition = [0 0 0];
fd2_rx_mod_params.antPolarization = {'v'};
fd2_rx_mod_params.antAzimuth = [0];
fd2_rx_mod_params.antElevation = [0];
fd2_rx_mod_params.exteriorWallMaterial = 'none';
fd2_rx_mod_params.distToExteriorWall = [0];
fd2_rx_mod_params.exteriorBldgAngle = [0];
fd2_rx_mod_params.numInteriorWalls = [0];

fd1_tx_mod = module(fd1_tx_mod_params);
fd1_rx_mod = module(fd1_rx_mod_params);
fd2_tx_mod = module(fd2_tx_mod_params);
fd2_rx_mod = module(fd2_rx_mod_params);


% Define nodes

FD_userA_node_params.name = 'FD_UserA';
FD_userA_node_params.location = [0 100 2];
FD_userA_node_params.velocity = [0 0 0];
FD_userA_node_params.controllerFcn = @FD_UserA_Controller;
FD_userA_node_params.modules = [fd1_tx_mod fd2_rx_mod];

FD_userB_node_params.name = 'FD_UserB';
FD_userB_node_params.location = [200 100 2];
FD_userB_node_params.velocity = [0 0 0];
FD_userB_node_params.controllerFcn = @FD_UserB_Controller;
FD_userB_node_params.modules = [fd2_tx_mod fd1_rx_mod];

FD_userA_node = node(FD_userA_node_params);
FD_userB_node = node(FD_userB_node_params);


% Set user parameters

userParams.power = 10; % (Watts)
userParams.dataLen = 1800;
userParams.trainingLen = 200;
userParams.nOversamp = 3;
userParams.bitLen = userParams.dataLen+userParams.trainingLen;
userParams.blockLen = userParams.nOversamp*userParams.bitLen;

userParams.trainingSeq = rand(1,userParams.trainingLen)>.5;

userParams.nBlocksToSim = 10;
userParams.receivedBlocks = 0;
userParams.transmittedBlocks = 0;

userParams.txBits = zeros(userParams.nBlocksToSim,userParams.bitLen,'uint8');
userParams.rxBits = zeros(userParams.nBlocksToSim+1,userParams.bitLen,'uint8');

userParams.equalizerLen = 21;
userParams.equalizerDelay = 10;

userA_node = SetUserParams(FD_userA_node,userParams);
userB_node = SetUserParams(FD_userB_node,userParams);


% Put nodes into output array
fdNodes = [userA_node userB_node];





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


