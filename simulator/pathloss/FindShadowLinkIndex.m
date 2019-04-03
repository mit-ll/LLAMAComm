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


