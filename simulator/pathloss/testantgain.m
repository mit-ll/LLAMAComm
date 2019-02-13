% both indoors

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

scenario = loadScenario('urban1');
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
[Ldb, Fext] = getPathloss(txnode, rxnode, env);


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


