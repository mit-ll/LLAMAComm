function [linkobj, I] = FindLink(links, fromID, toID)

% Function @link/FindLink.m:
% Searches an array of link objects and returns the link object
% with the matching fromID and toID.
%
% USAGE: linkobj = FindLink(links, fromID, toID)
%
% Input arguments:
%  fromID   (cell array of strings) ID for "from" module
%  toID     (cell array of strings) ID for "to" module
%
% Output argument:
%  linkobj  (link obj) Link object, returns empty if no match
%  I        (int) Index for matching link object, returns -1 if no match
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

chk = false(1, length(links));
for k = 1:length(links)
  if isequal(links(k).fromID, fromID)
    chk(k) = isequal(links(k).toID, toID);
  end  
end
I = find(chk);
count = numel(I);
if count > 1
  error('@link/FindLink: Duplicate toID/fromID pair found!');
end

if count == 0
  linkobj = []; % Backwards compatibility
else
  linkobj = links(chk);
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


