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


