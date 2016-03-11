function [nNewLinks,corrLossOld] = GetNumNewLinks(nodes,linkMatrix)
% Function '@node/GetNumNewLinks.m':  
%  Gets the number of new links and returns the old shadow corr loss
%
% USAGE:  [nNewLinks,corrLossOld] = GetNumNewLinks(nodes,linkMatrix)
%
% Input arguments:
%  nodes       (node obj array) Node object array
%  linkMatrix  (double matrix) Link matrix between all nodes
%
% Output argument:
%  nNewLinks   (int) The number of new links from the previous simulation
%  corrLossOld (double array) Old correlation loss array
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Count the number of new nodes and get the old correlation loss
nNewNodes = 0;
for nodeLoop = 1:length(nodes)
    p = GetUserParams(nodes(nodeLoop));
    
    if isfield(p,'newNode')
        nNewNodes = nNewNodes + 1;
        corrLossOld = p.corrLossOld;
    end
end

% Output empty matrix if this is a normal llamacomm run
if nNewNodes == 0
    corrLossOld = [];
end

% Now determine the number of new links
nNewLinks = 0;
for linkLoop = 1:nNewNodes
    for nLoop = linkLoop + 1:length(nodes)
        % Count the number of links
        if linkMatrix(linkLoop,nLoop)
            nNewLinks = nNewLinks + 1;
        end
    end
end

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


