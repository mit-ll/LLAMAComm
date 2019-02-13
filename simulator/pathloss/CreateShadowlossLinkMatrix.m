function linkMatrix = CreateShadowlossLinkMatrix(nodeArray)

% Function 'pathloss/CreateShadowlossLinkMatrix.m':  
%  Creates matrix of links between nodes in the nodeArray
%
% USAGE:  env = CreateShadowLossLinkMatrix(nodeArray)
%
% Input arguments:
%  nodeArray (struct array) structure with the following fields
%   .type      (string) 'transmitter', 'receiver', or 'transceiver'
%   .name      (string) Node name returned by GetName(nodeobj)
%   .location  (1 x 3 double) (m) 3-D location of node
%
% Output argument:
%  linkMatrix  (N x N double) Boolean symmetric matrix indicating 
%                             links between nodes.  N is the number 
%                             of nodes.
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

% Number of relevant nodes
nNodes = length(nodeArray);

% The following code loops through the nodeArray and finds 'transmitter' 
% or 'transceiver' nodes.  The indices correspond to the rows of the
% link matrix.  For each transmitter or transceiver, the code loops again
% over the nodeArray from the beginning and places a '1' in 
% every column corresponding to 'receiver' or 'transceiver' 
% nodes.

% Create the link matrix
linkMatrix = zeros(nNodes);
for rowLoop = 1:nNodes
    switch nodeArray(rowLoop).type
        case {'transmitter','transceiver'}
            for colLoop = 1:nNodes
                switch nodeArray(colLoop).type
                    case {'receiver','transceiver'}
                        linkMatrix(rowLoop,colLoop) = 1;
                end
            end % END colLoop
    end
end % END rowLoop

% Make the matrix symmetric
linkMatrix = linkMatrix | linkMatrix.';

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


