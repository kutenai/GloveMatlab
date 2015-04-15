function [ang]=quat2euler(b)
% This function converts a quaternion to Euler angles as described
% in Addendix D of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.
b = b/norm(b);

ang(1)  = limit(atan2(2*(b(3)*b(4)-b(1)*b(2)),1-2*(b(2)^2+b(3)^2)));
ang(2)  = asin(-2*(b(2)*b(4)+b(1)*b(3)));
ang(3)  = limit(atan2(2*(b(2)*b(3)-b(1)*b(4)),1-2*(b(3)^2+b(4)^2)));




function [y]=limit(x)

while x>pi
    x=x-2*pi;
end
while x<=-pi
    x=x+2*pi;
end
y=x;