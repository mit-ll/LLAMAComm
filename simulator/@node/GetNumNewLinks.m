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


