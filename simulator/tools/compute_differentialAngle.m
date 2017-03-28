function [az,el] = compute_differentialAngle(az,el,azRef,elRef)
% Given two sets of angles (az,el) and (azRef,elRef) in a common refernece
% system, rotate the reference system so the (azRef,elRef) = (0,0) and
% return the updated (az,el) with respect to this new reference system.
% 
% The convention adopted is that of MATLAB's cart2sph:
%   Azimuth is computed counter-clockwise in the x-y plane from [1,0,0]
%   Elevation is the angle subtended between the vector and the x-y plane. 
%

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