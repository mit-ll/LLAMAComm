function linkNames = GetShadowlossLinkNames(nodeArray, linkMatrix)

% Function 'pathloss/GetShadowlossLinkNames.m':  
%
% USAGE:  env = GetShadowlossLinkNames(nodeArray, linkMatrix)
%
% Input arguments:
%  nodeArray (struct array) structure with the following fields
%   .type      (string) 'transmitter', 'receiver', or 'transceiver'
%   .name      (string) Node name returned by GetName(nodeobj)
%   .location  (1 x 3 double) (m) 3-D location of node
%
%  linkMatrix  (N x N double) Symmetric Boolean matrix indicating 
%                             links between nodes.  N is the number 
%                             of nodes.
%
% Output argument:
%  Krho        (M x M double) Shadowloss correlation matrix. M is the
%                             number of links.

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

linkNum = 0;
nNodes = length(nodeArray);
maxNames = 0.5*(nNodes*(nNodes-1));
linkNames = cell(1, maxNames);

% Determine the link names, i.e., scan the links off the diagonal
% of the upper-triangle of the link matrix.
for rowLoop = 1:nNodes-1
  for colLoop = rowLoop+1:nNodes
    if linkMatrix(rowLoop, colLoop)
      linkNum = linkNum + 1;
      linkNames{linkNum} = {nodeArray(rowLoop).name, ...
                          nodeArray(colLoop).name};
    end
  end % END colLoop
end % END rowLoop
linkNames = linkNames(1:linkNum);

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


