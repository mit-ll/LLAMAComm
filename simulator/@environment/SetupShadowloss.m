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


