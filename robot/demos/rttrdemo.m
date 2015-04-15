%RTTRDEMO Transforms and quaternion demo

% Copyright (C) 1993-2002, by Peter I. Corke
% $Log: not supported by cvs2svn $
% Revision 1.2  2002-04-01 11:47:18  pic
% General cleanup of code: help comments, see also, copyright, remnant dh/dyn
% references, clarification of functions.
%
% $Revision: 1.1 $
echo on
%
% In the field of robotics there are many possible ways of representing 
% positions and orientations, but the homogeneous transformation is well 
% matched to MATLABs powerful tools for matrix manipulation.
%
% Homogeneous transformations describe the relationships between Cartesian 
% coordinate frames in terms of translation and orientation.  

%  A pure translation of 0.5m in the X direction is represented by
    transl(0.5, 0.0, 0.0)
%
% a rotation of 90degrees about the Y axis by
    troty(pi/2)
%
% and a rotation of -90degrees about the Z axis by
    trotz(-pi/2)
%
%  these may be concatenated by multiplication
    t = transl(0.5, 0.0, 0.0) * troty(pi/2) * trotz(-pi/2)

%
% If this transformation represented the origin of a new coordinate frame with respect
% to the world frame origin (0, 0, 0), that new origin would be given by

        t * [0 0 0 1]'
pause % any key to continue
%
% the orientation of the new coordinate frame may be expressed in terms of
% Euler angles
    tr2eul(t)
%
% or roll/pitch/yaw angles
    tr2rpy(t)
pause % any key to continue
%
% It is important to note that tranform multiplication is in general not 
% commutative as shown by the following example
    trotx(pi/2) * trotz(-pi/8)
    trotz(-pi/8) * trotx(pi/2)
%
%
pause % any key to continue
echo off
