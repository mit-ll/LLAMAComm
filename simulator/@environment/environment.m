function env = environment(a)

% ENVIRONMENT class constructor

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

if nargin == 0
    env = emptyEnvironment;
    env = class(env,'environment');
elseif isa(a,'environment')
    env = a;
elseif isstruct(a)
    env = emptyEnvironment;

    env.envType = a.envType;
    env.propParams = FieldCopy(env.propParams, a.propParams);

    if isfield(a, 'building')
      env.building = FieldCopy(env.building, a.building);
    end

    if isfield(a, 'shadow')
      env.shadow = a.shadow;
    end

    if isfield(a, 'links')
      env.links = a.links;
    end

    if isfield(a, 'atmosphere')
      env.atmosphere = FieldCopy(env.atmosphere, a.atmosphere);
    end

    env = class(env, 'environment');
else
    error('Bad input argument to ENVIRONMENT constructor.');
end

function env = emptyEnvironment()

% Environment parameters that are constant for the simulation
env.envType = '';

env.propParams.delaySpread = [];          % s
env.propParams.velocitySpread = [];       % m/s
env.propParams.alpha = [];                % Used only for 'STFCS' channel
env.propParams.longestCoherBlock = [];    % s
env.propParams.stfcsChannelOversamp = [];      % Used only for 'STFCS' channel
env.propParams.wssusChannelTapSpacing = []; % samples
env.propParams.los_dist = 50;             % m
env.propParams.linkParamFile = [];        % string


%
env.building.avgRoofHeight = [];          % m

% Database of links built as-needed
env.links = [];

% Shadowloss parameters, created in Main.m
env.shadow = [];

% Atmospheric parameters
env.atmosphere.latd = [];
env.atmosphere.season = [];



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


