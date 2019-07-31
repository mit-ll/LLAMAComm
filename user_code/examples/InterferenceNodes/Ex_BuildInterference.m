function interfNodes = Ex_BuildInterference

% Function Ex_BuildInterference.m:
% Example function for building interference nodes.
% This function returns 2 transmit-only nodes:
%  1. Complex colored gaussian noise in the FM band
%  2. Complex white gaussian noise in the ISM band
%
% USAGE: interfNodes = Ex_BuildInterference
%
% Input arguments:
%  -none-
%
% Output arguments:
%  interfNodes  (1xN Node obj array) Newly-created interference nodes
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


% Build FM interferer based on CWGN module/controller

fm_mod_params.name = 'ccgn_tx';
fm_mod_params.callbackFcn = @CCGN_Transmit;
fm_mod_params.fc = 99.5e6;
fm_mod_params.type = 'transmitter';
fm_mod_params.loError = 0;
fm_mod_params.antType = {'dipole_halfWavelength'};
fm_mod_params.antPosition = [0 0 0];
fm_mod_params.antPolarization = {'v'};
fm_mod_params.antAzimuth = [0];
fm_mod_params.antElevation = [0];
fm_mod_params.exteriorWallMaterial = 'none';
fm_mod_params.distToExteriorWall = [0];
fm_mod_params.exteriorBldgAngle = [0];
fm_mod_params.numInteriorWalls = [0];

fm_interf_mod = module(fm_mod_params);

fm_node_params.name = 'Interf_FM';
fm_node_params.location = [0 -400 30];
fm_node_params.velocity = [0 0 0];
fm_node_params.controllerFcn = @CCGN_Controller;
fm_node_params.modules = [fm_interf_mod];

fm_interf_node = node(fm_node_params);

fm_user_params.transmittedBlocks = 0;
fm_user_params.nBlocksToTx = 21;
fm_user_params.blockLen = 3377;
fm_user_params.power = 1; % (Watts) transmit power

interfNodes = SetUserParams(fm_interf_node,fm_user_params);


% Build ISM interferer based on CWGN module/controller

ism_mod_params.name = 'cwgn_tx';
ism_mod_params.callbackFcn = @CWGN_Transmit;
ism_mod_params.fc = 2495e6;
ism_mod_params.type = 'transmitter';
ism_mod_params.loError = 0;
ism_mod_params.antType = {'dipole_halfWavelength'};
ism_mod_params.antPosition = [0 0 0];
ism_mod_params.antPolarization = {'v'};
ism_mod_params.antAzimuth = [0];
ism_mod_params.antElevation = [0];
ism_mod_params.exteriorWallMaterial = 'none';
ism_mod_params.distToExteriorWall = [0];
ism_mod_params.exteriorBldgAngle = [0];
ism_mod_params.numInteriorWalls = [0];

ism_interf_mod = module(ism_mod_params);

ism_node_params.name = 'Interf_ISM';
ism_node_params.location = [100 500 20];
ism_node_params.velocity = [0 0 0];
ism_node_params.controllerFcn = @CWGN_Controller;
ism_node_params.modules = [ism_interf_mod];

ism_interf_node = node(ism_node_params);

ism_user_params.transmittedBlocks = 0;
ism_user_params.nBlocksToTx = 30;
ism_user_params.blockLen = 2390;
ism_user_params.power = 1; % (Watts) transmit power

interfNodes(2) = SetUserParams(ism_interf_node,ism_user_params);


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


