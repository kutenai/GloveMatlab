al=40*pi/180; % angle of velocity at the bigining 
v0=10; % initial velocity
g=9.8; % gravitation constant
vx=v0*cos(al); 
vy=v0*sin(al); % initial velocities
x=0; 
y=0; % initial position
dt=0.02; % time step
sgx=0.02; % sigma_x - nose lavel for x
sgy=0.02; % sigma_y - nose lavel for y

% generate original trajectory:
xa=[]; % here x coordinaties will be stored
ya=[]; % here y coordinaties will be stored
vxa=[]; % here x-component of velocity  will be stored
vya=[]; % here y-component of velocity  will be stored
ta=[]; % here times will be stored
xna=[]; % here noised x coordinaties will be stored
yna=[]; % here noised y coordinaties will be stored
t=0; % start time
while 1 % infinite loop, break used
    
    
    xa=[xa x];
    ya=[ya y];
    vxa=[vxa vx];
    vya=[vya vy];
    ta=[ta t];
    xna=[xna x+sgx*randn]; 
    yna=[yna y+sgy*randn]; % add gaussian noise
    
    if y<0 % when return to ground
        break % stop motion
    end
    
    % update values
    x=x+vx*dt; % vx~(x(k+1)-x(k))/dt => x(k+1)~x(k)+vx*dt
    y=y+vy*dt;
    vy=vy-g*dt;
    t=t+dt;
    % note: vx not change
    
    
end

% plot nosied trajectory
%plot(xa,ya,'b-',xna,yna,'r--');
figure;
plot(xna,yna,'b-');
xlabel('x, m');
ylabel('y, m');
%legend('real curve','noised curve');



% apply kalman filtering:
R=[sgx^2   0     
   0       sgy^2]; % covariance matrix for nose in x and y 

H=[1 0 0 0 0;
   0 0 1 0 0]; % observarion matrix

F=[ 1  dt 0  0  0
    0  1  0  0  0
    0  0  1  dt 0
    0  0  0  1  dt
    0  0  0  0  1  ]; % state transition matrix

P=eye(5); % inital gues for P-matrix

I=eye(5); % unit matrix

% estimated state vector form:
%   xc =[ x
%         vx
%         y
%         vy
%         ay ]

xc=[xna(1)
    0
    yna(1)
    0
    0]; % guess for initial value of estimation of state vector
% for x y get initial noised position, for vx vy ay is zeros

z=[xna
   yna]; % observation

xca=xc; % will be stored in xca
nc=2; % loop counter, stert from second step
for t=ta(2:end)
    Ps=F*P*F';
    K=Ps*H'*(H*Ps*H'+R)^(-1);
    xc=F*xc+K*(z(:,nc)-H*F*xc);
    P=(I-K*H)*Ps*(I-K*H)'+K*R*K';
    %P=(I-K*H)*Ps;
    xca=[xca xc]; % store
    nc=nc+1;
end

% add to plot filtered tragectory:
hold on;
plot(xca(1,:),xca(3,:),'r-','linewidth',2);
legend('noised','filtered');
title('trajectory');

% plot velocities graph in separated window:
figure;
plot(ta,xca(2,:),'r-','linewidth',2);
hold on;
plot(ta,vxa,'r--');
plot(ta,xca(4,:),'b-','linewidth',2);
plot(ta,vya,'b--');
xlabel('time, s');
legend('filtered vx','original vx','filtered vy','original vy');
title('velocities');



