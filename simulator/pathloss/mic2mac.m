function xyzout = mic2mac(macxyz,micxyz)
% function xyzout = mic2mac(macxyz,micxyz)

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

% Inputs:  macxyz (1 x 3 real) reference point coordinates on macro axes
%          micxyz (1 x 3 real) point of interest coordinates on micro axes
% Outputs: xyzout (1 x 3 real) point of interest coordinates on macro axes

% In the following, the micro and macro axes are assumed to be
% alligned.
xyzout = macxyz + micxyz;


% % Given node reference point coordinates on macro axes (centered
% % on DN, with x due East, and y due North) and micro coordinates 
% % within node (centered on reference point, with y away from DN
% % and x to right looking at node from DN) find macro coordinates
% % of specified location.
%
% xyzout = zeros(size(macxyz));
%
% if macxyz(1)==0 & macxyz(2)==0 % node is DN at macro-origin
% 
%    xyzout(1:2) = micxyz(1:2);   % micro and macro axes are same
%    xyzout(3) = macxyz(3) + micxyz(3); % except maybe height
% 
% else % node isn't DN
% 
%    theta = atan2(macxyz(2),macxyz(1)); % node angle in macro axes
% 
%    xyzout(1) = macxyz(1) + micxyz(1)*sin(theta) + micxyz(2)*cos(theta);
%    xyzout(2) = macxyz(2) - micxyz(1)*cos(theta) + micxyz(2)*sin(theta);
%    xyzout(3) = macxyz(3) + micxyz(3); % ignores earth curvature
% 
% end;


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


