function env = environment(a)

% ENVIRONMENT class constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    env = class(env,'environment');
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


