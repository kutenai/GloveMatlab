function [b]=rot2quat(R)
threshold = 0.1
% first, normalized the matrix
[U,S,V]=svd(R);
R = U*V'

% select the best of the four solution methods
T(1) = 1+R(1,1)+R(2,2)+R(3,3);
T(2) = 1+R(1,1)-R(2,2)-R(3,3);
T(3) = 1-R(1,1)+R(2,2)-R(3,3);
T(4) = 1-R(1,1)-R(2,2)+R(3,3);
[T,ind]=max(T);
switch ind
case  1,  % b1 solution
    b1(1,1)    = 0.5*sqrt(T);
    b1(2,1)    = (R(3,2)-R(2,3))/4/b1(1);         % checked
    b1(3,1)    = (R(1,3)-R(3,1))/4/b1(1);         % checked
    b1(4,1)    = (R(2,1)-R(1,2))/4/b1(1);         % checked
    b       = b1/norm(b1);    % renormalize
case  2,  % b2 solution
    b(2,1)    = 0.5*sqrt(T);
    b(1,1)    = (R(3,2)-R(2,3))/4/b(2);         % checked
    b(3,1)    = (R(1,2)+R(2,1))/4/b(2);         % checked
    b(4,1)    = (R(3,1)+R(1,3))/4/b(2);         % checked
    b       = b/norm(b)    % renormalize 
    %R2 = quat2R(b)
case  3,  % b3 solution
    b(3,1)    = 0.5*sqrt(T);
    b(1,1)    = (R(1,3)-R(3,1))/4/b(3);         % checked
    b(2,1)    = (R(1,2)+R(2,1))/4/b(3);         % checked
    b(4,1)    = (R(2,3)+R(3,2))/4/b(3);         % checked
    b      = b/norm(b);    % renormalize 
case  4,  % b4 solution
    b(4,1)    = 0.5*sqrt(T);
    b(1,1)    = (R(2,1)-R(1,2))/4/b(4);         % checked
    b(2,1)    = (R(1,3)+R(3,1))/4/b(4);         % checked
    b(3,1)    = (R(2,3)+R(3,2))/4/b(4);         % checked
    b       = b/norm(b)    % renormalize 
otherwise
    error('Error in Rot 2 Quat')    
end

quat2R(b)


% convert a quaternion b to a rotation matrix
% eqn (D13) works for any normal quaternion
function [Rn2b]=quat2R(b)
if norm(b)~= 0,
    b = b/norm(b);
    B = b(1);
    Bv(:,1)= b(2:4);
    Bc = [0    -Bv(3) Bv(2)
         Bv(3)  0    -Bv(1)
        -Bv(2)  Bv(1) 0];
    Rn2b = (B*B-Bv'*Bv)*eye(3,3)+2*Bv*Bv'+2*B*Bc;
else
    Rn2b = eye(3,3)    % fault condition
    error('Norm b = 0');
end