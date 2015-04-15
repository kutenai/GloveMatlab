function [dx]=Quat(u)
% This function implements the quaternion integration as described
% in Addendix D of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.
approach = 2;

w_bi_b= -u(5:7);     % angular rate of body wrt inertial in body

if approach ==1,
    b1 = u(1);
    b_v(1:3,1) = u(2:4);
    Omga =[-b_v'
        b1*eye(3,3)-cross(b_v)]/2;
    dx = Omga*w_bi_b;       
else
    b(1:4,1) = u(1:4);
    Q = [0       -w_bi_b'
        w_bi_b  cross(w_bi_b)];
    dx = Q*b/2;
end
    

function [y]=cross(x)
y = [ 0 -x(3) x(2)
      x(3) 0 -x(1)
      -x(2) x(1) 0];