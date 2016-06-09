function k = link(a)

% LINK class constructor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    k = emptyLink;
    k = class(k,'link');
elseif isa(a,'link')
    k = a;
elseif isstruct(a)
    k = emptyLink;
    
    % Channel information
    k.channel = a.channel;
    k.pathLoss = a.pathLoss;
    k.chanTail = a.chanTail;
    k.propParams = a.propParams;

    % Inband filter information
    k.filterTaps = a.filterTaps;
    
    % Anti-alias filter
    k.antialiasTaps = a.antialiasTaps;
    
    % Link ID's
    k.fromID = a.fromID;
    k.toID = a.toID;
    
    k = class(k,'link');
else
    error('Bad input argument to LINK constructor.');
end


function k = emptyLink()

% Channel information
k.channel = [];
k.pathLoss = [];
k.chanTail = [];
k.propParams = [];

% Inband filter information
k.filterTaps = [];
k.filterTail = [];
k.freqOverlapMethod = [];

% Anti-alias filter
k.antialiasTaps = [];

% Filter and Channel tails are valid to this sample number
k.validTo = [];

% Link ID's
k.fromID = {};  % {nodeName, moduleName}
k.toID = {};    % {nodeName, moduleName, fc}

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


