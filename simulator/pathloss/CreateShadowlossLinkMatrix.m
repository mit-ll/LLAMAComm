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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


