function env = SetupShadowloss(env,nodes)

% Function '@environment/SetupShadowloss.m':  
%  Populates the shadowLoss field in the environment object with the
%  properly-correlated shadowloss realization.  The realization
%  still needs to be weighted by the standard deviation
%  returned by GetShadowloss.m.
%
% USAGE:  env = SetupShadowloss(env,nodes)
%
% Input arguments:
%  env       (environment obj) Environment object
%  nodes     (node obj array) Node object array
%
% Output argument:
%  env       (environment obj) Modified environment object
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a struct array of node-module locations and node-module names
% that define the link matrix
nodeArray = CreateShadowlossNodeArray(nodes);

% Create a link matrix of node-module pairs
linkMatrix = CreateShadowlossLinkMatrix(nodeArray);

% Get the shadowloss correlation matrix (Bruce's code)
[Krho,linkNames] = GetShadowlossCorrMatrix(nodeArray,linkMatrix);

% determine the number of new links
[nNewLinks,corrLossOld] = GetNumNewLinks(nodes,linkMatrix);

if nNewLinks > 0
    % Augment the old correlation loss
    corrLoss = augmentRandNVec(corrLossOld,Krho);
else
    % Generate the un-weighted correlated shadowloss realization
    corrLoss = sqrtm(Krho)*randn(size(Krho,1),1);
end

% Set environment parameters
env.shadow.nodeArray = nodeArray;
env.shadow.linkMatrix = linkMatrix;
env.shadow.Krho = Krho;
env.shadow.corrLoss = corrLoss;
env.shadow.linkNames = linkNames;

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


