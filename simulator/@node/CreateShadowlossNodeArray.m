function nodeArray = CreateShadowlossNodeArray(nodes)
% Function '@node/CreateShadowlossNodeArray.m':  
%  Creates the array of nodes
%
% USAGE:  env = CreateShadowlossNodeArray(nodes)
%
% Input arguments:
%  nodes     (node obj array) Node object array
%
% Output argument:
%  nodeArray (struct array) structure with the following fields
%   .type      (string) 'transmitter', 'receiver', or 'transceiver'
%   .name      (string) Node name returned by GetName(nodeobj)
%   .location  (1 x 3 double) (m) 3-D location of node
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

% Allocate nodeArray
nodeArray(1, length(nodes)) = struct('type','','name','','location','');

for nodeLoop = 1:length(nodes)
    
    % Find transmitter and receiver modules
    transmitter = 0;
    receiver = 0;
    for modLoop = 1:length(nodes(nodeLoop).modules)
        if ~IsGenie(nodes(nodeLoop).modules(modLoop))
            switch GetType(nodes(nodeLoop).modules(modLoop))
                case 'transmitter'
                    transmitter = 1;
                case 'receiver'
                    receiver = 1;
            end
        end
    end % END moduleLoop
    
    % Determine node type: 'transmiter', 'receiver', 'transceiver'
    type = [transmitter receiver];
    switch [num2str(type(1)) num2str(type(2))]
        case '00'
            % Do nothing, must be Genie only
        case '10'
            nodeArray(nodeLoop).type = 'transmitter';
        case '01'
            nodeArray(nodeLoop).type = 'receiver';
        case '11'
            nodeArray(nodeLoop).type = 'transceiver';
    end
    
    % Set the name and location of the node
    if ~isempty(find(type, 1))
        nodeArray(nodeLoop).name = nodes(nodeLoop).name;
        nodeArray(nodeLoop).location = nodes(nodeLoop).location;
    end
    
end % END nodeLoop

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


