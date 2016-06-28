function [linkobj] = FindReciprocalLink(links, nodeTx, modTx, nodeRx, modRx, nodes)

% Function @link/FindReciprocalLink.m:
% Searches an array of link objects and returns the link object
% with a reciprocal channel.
%
% USAGE: linkobj = FindReciprocalLink(links, nodeTx, modTx, nodeRx, modRx, nodes)
%
% Input arguments:
%  links    (link obj array) Array of link objects
%  nodeTx   (node obj) Node transmitting
%  modTx    (module obj) Module transmitting
%  nodeRx   (node obj) Node receiving
%  modRx    (module obj) Module receiving
%  nodes    (node obj array) Array of node objects
%
% Output argument:
%  linkobj  (link obj) Link object, returns empty if no reciprocal link
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkobj = [];
linkCount = 0;

if ~isempty(links)
  nodeTxName     = GetNodeName(nodeTx);
  nodeRxName     = GetNodeName(nodeRx);
  frequency      = GetFc(modRx);
  linkNodeTx = FindNode(nodes, nodeRxName);
  linkNodeTxStruct = struct(linkNodeTx);

  linkNodeRx = FindNode(nodes, nodeTxName);
  linkNodeRxStruct = struct(linkNodeRx);

  for linkIndx = 1:length(links)

    linkNodeTxName = links(linkIndx).fromID{1};
    linkNodeRxName = links(linkIndx).toID{1};
    linkFrequency  = links(linkIndx).toID{3};
    
    % Check to see if the fromNode and toNode and center frequency are reciprocal
    if isequal({linkNodeTxName, linkNodeRxName, linkFrequency},...
               {    nodeRxName,     nodeTxName,     frequency})
      
      txModNum   = GetModNum(linkNodeTx,links(linkIndx).fromID{2});
      linkModTx  = linkNodeTxStruct.modules(txModNum);
      
      rxModNum   = GetModNum(linkNodeRx,links(linkIndx).toID{2});
      linkModRx  = linkNodeRxStruct.modules(rxModNum);
      
      % Check to see if the tx and rx modules in each node have the same
      % antenna properties
      if isequal(GetAntennaParams(modTx), GetAntennaParams(linkModRx)) && ...
            isequal(GetAntennaParams(modRx), GetAntennaParams(linkModTx))

        linkobj = links(linkIndx);
        linkCount = linkCount + 1;
      end
    end

  end
  if linkCount > 1
    error('More than on reciprocal link in link object array!')
  end
end



% chk = false(1, length(links));
% for k = 1:length(links)
%   if isequal(links(k).fromID, fromID)
%     chk(k) = isequal(links(k).toID, toID);
%   end  
% end
% I = find(chk);
% count = numel(I);
% if count > 1
%   error('@link/FindLink: Duplicate toID/fromID pair found!');
% end
% 
% if count == 0
%   linkobj = []; % Backwards compatibility
% else
%   linkobj = links(chk);
% end

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


