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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


