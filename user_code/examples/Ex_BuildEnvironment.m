function env = Ex_BuildEnvironment

% Function Ex_BuildEnvironment.m:
% Builds an example rural environment object.
%
% USAGE: env = Ex_BuildEnvironmentt
%
% Input args:
%  -none-
%
% Output arguments:
%  env    (environment object) New environment object
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

test_env_params.envType = 'rural';
test_env_params.propParams.delaySpread = .2e-6;  % sec
test_env_params.propParams.velocitySpread = 0.1;  % m/s
test_env_params.propParams.alpha = 0.5;
test_env_params.propParams.longestCoherBlock = 1;
test_env_params.propParams.stfcsChannelOversamp = 3;
test_env_params.propParams.wssusChannelTapSpacing = []; % samples
test_env_params.propParams.los_dist = 10;             % m
test_env_params.building.avgRoofHeight = 4;
env = environment(test_env_params);


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


