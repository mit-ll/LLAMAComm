function linkIndex = FindShadowLinkIndex(linkNames,txName,rxName)

% Function 'pathloss/FindShadowLinkIndex.m':  
% Finds the index of the shadow link with corresponding name
%
% USAGE:  linkIndex = FindShadowLinkIndex(linkNames,txName,rxName)
%
% Input arguments:
% linkNames   (cell array) link names: {NodeName, NodeName}
% txName      (string) Name of transmitting node
% rxName      (string) Name of receiving node
%
% Output argument:
%  linkIndex  (int) Index of shadow link
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

found = 0;
for linkIndex = 1:length(linkNames)
    % Try to match transmitter and receiver node names with link names
    found = (strcmp(linkNames{linkIndex}{1},txName)...
            &strcmp(linkNames{linkIndex}{2},rxName))...
           |(strcmp(linkNames{linkIndex}{2},txName)...
            &strcmp(linkNames{linkIndex}{1},rxName));
    if found
      break;
    end
end

if ~found
    error('Shadowlink Index is not found!')
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


