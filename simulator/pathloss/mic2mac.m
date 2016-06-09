function xyzout = mic2mac(macxyz,micxyz)
% function xyzout = mic2mac(macxyz,micxyz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


