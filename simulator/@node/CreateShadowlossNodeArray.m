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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    switch [num2str(type(1)) num2str(type(2))];
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


