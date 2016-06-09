% both indoors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ scenario ] = loadScenario('urban1');
scenario.name = 'rural';

% Build DN
ruParam.intwalls = 0;
ruParam.extawallmat = 'none';
ruParam.intdist = 3;
ruParam.extbldgangle = 70;

rxParam.fcmhz = 100;
rxParam.bwmhz = [-4 4];
rxParam.polarize = 'v';

rxnode = node('testrx', 'user', [ 100 0 1 ], [0 0 0]);
rxnode = setNodeUserParams(rxnode, ruParam);
rxnode = setNodeRxParams(rxnode, rxParam);

% Build AN
tuParam.intwalls = 1;
tuParam.extawallmat = 'none';
tuParam.intdist = 10;
tuParam.extbldgangle = 70;

txParam.fcmhz = 100;
txParam.bwmhz = [-4 4];
txParam.polarize = 'v';

txnode = node('testtx', 'user', [ 0 0 1 ], [0 0 0]);
txnode = setNodeUserParams(txnode, tuParam);
txnode = setNodeTxParams(txnode, txParam);

% Make fake environment
env.scenarioType = scenario.name;
env.building.roofHeight = 30;

% Test pathloss
[ Ldb Fext ] = getPathloss(txnode, rxnode, env);


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


