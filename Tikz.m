phi = 30*pi/180
theta = 44*pi/180
psi = 30*pi/180
theta1 = -110*pi/180
phi1 = 145*pi/180

Rmain1 = [cos(phi1),-sin(phi1),0;sin(phi1),cos(phi1),0;0,0,1];
Rmain2 = [1,0,0;0,cos(theta1),-sin(theta1);0,sin(theta1),cos(theta1)];

Rmain = (Rmain1*Rmain2)'

% Now calculate the rotated matrix..
Rphi = [1,0,0;0,cos(phi),sin(phi);0,-sin(phi),cos(phi)]
Rtheta = [cos(theta),0,-sin(theta);0,1,0;sin(theta),0,cos(theta)]
Rpsi = [cos(psi),sin(psi),0;-sin(psi),cos(psi),0;0,0,1]

Rrot = Rmain*Rphi*Rtheta*Rpsi


