function m = module(a,genieFlag)

% MODULE class constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    m = emptyModule;
    m = class(m,'module');

elseif isa(a,'module')
    m = a;

elseif isstruct(a)
    if exist('genieFlag','var') && genieFlag==1
        % Create special genie module
        m = emptyModule;
        m.isGenie = 1;
        m.name = a.name;
        switch a.type
            case {'transmitter','receiver'}
                m.type = a.type;
            otherwise
                error('Module type must be ''transmitter'' or ''receiver''');
        end
        m = class(m,'module');

    else
        % Create normal module
        m = emptyModule;
        
        % Required fields
        m.name = a.name;
        m.fc = a.fc;
        switch a.type
            case {'transmitter','receiver'}
                m.type = a.type;
            otherwise
                error('Module type must be ''transmitter'' or ''receiver''');
        end
        m.callbackFcn = a.callbackFcn;
        m.loError = a.loError;
        if isfield(a,'loCorrection')
            m.loCorrection = a.loCorrection;
        else
            m.loCorrection = 0;
        end
        if strcmp(a.type,'receiver')
            m.noiseFigure = a.noiseFigure;
        end
        m.antType = a.antType;
        m.antPosition = a.antPosition;
        m.antPolarization = a.antPolarization;
        m.antAzimuth = a.antAzimuth;
        m.antElevation = a.antElevation;
        m.exteriorWallMaterial = a.exteriorWallMaterial;
        m.distToExteriorWall = a.distToExteriorWall;
        m.exteriorBldgAngle = a.exteriorBldgAngle;
        m.numInteriorWalls = a.numInteriorWalls;
        
        % Optional fields
        if isfield(a,'TDCallbackFcn')
            m.TDCallbackFcn = a.TDCallbackFcn;
        end
        
        m = class(m,'module');
    end

else
    error('Bad input argument to MODULE constructor.');
end


function m = emptyModule()

global simulationSampleRate

% Defined on object creation
m.name = '';
m.fc = [];
m.fs = simulationSampleRate;
m.type = '';
m.callbackFcn = [];
m.TDCallbackFcn = [];

m.loError = [];
m.loCorrection = [];
m.noiseFigure = [];
m.antType = {};
m.antPosition = [];
m.antPolarization = {};
m.antAzimuth = [];
m.antElevation = [];
m.exteriorWallMaterial = '';
m.distToExteriorWall = [];
m.numInteriorWalls = [];
m.exteriorBldgAngle = [];

% Set by @module/SetRequest.m
m.job = '';
m.requestFlag = 0;
m.blockLength = [];

% Modified by @module/RequestDone.m
m.blockStart = 1;
m.history = {};

% Save file info, used bye @module/StoreSignal.m
m.filename = '';
m.fid = [];

% Special fields for genie tx/rx
m.isGenie = 0;
m.genieToNodeName = '';
m.genieToModName = '';
m.genieQueue = {};






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


