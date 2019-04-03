function [az,el] = compute_differentialAngle(az,el,azRef,elRef)
% Given two sets of angles (az,el) and (azRef,elRef) in a common refernece
% system, rotate the reference system so the (azRef,elRef) = (0,0) and
% return the updated (az,el) with respect to this new reference system.
%
% The convention adopted is that of MATLAB's cart2sph:
%   Azimuth is computed counter-clockwise in the x-y plane from [1,0,0]
%   Elevation is the angle subtended between the vector and the x-y plane.
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

Rot = @(theta) [ cos(theta),-sin(theta), 0;
                 sin(theta), cos(theta), 0;
                         0 ,         0 , 1];

% Rotate about z-axis first.
RotZ        = Rot(-azRef);
% Rotate about the new y-axis second.
RotX        = Rot(-elRef);
permutation = [1,3,2];      % swap roles of z and y.
% Apply rotations sequentially.
totalRot = RotX(permutation,permutation)*RotZ;

[x,y,z]   = sph2cart(az,el,1);
Y         = totalRot*[x;y;z];
[az,el,~] = cart2sph(Y(1),Y(2),Y(3));

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
