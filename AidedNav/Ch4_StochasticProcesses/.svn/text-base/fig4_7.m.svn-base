% This function implements the application of Section 4.9.4
% on p 159 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.
% 
%	Matlab example of Inertial Frame INS
%	error state estimation
%
clear
format compact

N	= 35;			% number of iterations
dt	= .1;			% simulation step
T 	= 1.0;			% sample period
m	= floor(T/dt+.5);	% sim steps per sample
F	=[0 1 0
	  0 0 1
	  0 0 0];
n=3
R = 2.5e-3;
Q = 1e-6;
Q=diag([0,R,Q]) % 2/2/2006 -- This is actually Gamma Q Gamma' 
chi = [ -F      Q
	0*eye(n) F']*dt;
gamma=expm(chi);
phi = gamma((n+1):(2*n),(n+1):(2*n))';
Qd  = phi*gamma(1:n,(n+1):(2*n));

chi = [ -F      Q
	0*eye(n) F']*T;
gamma=expm(chi);
phi_1 = gamma((n+1):(2*n),(n+1):(2*n))';
Qd_1  = phi_1*gamma(1:n,(n+1):(2*n))
clear chi gamma Q R F

Phi =[1 dt dt^2/2
      0 1  dt
      0 0  1];
H = [1 0 0];

% p=[.9+.1*j,.9-.1*j,.9];
% L = place(phi_1',H',p)';
L  = [0.3,0.039,0.002]'

eig(phi_1*(eye(3,3)-L*H))			% check

P_p = 0;
P_v = 0;
P_b = 0;
P=diag([P_p,P_v,P_b]);

R = 3.0;			% position measurement variance
D = eye(3) - L*H;

cnt = 0;
for i=1:N,
	for j=1:m,			% time propagation
		P = Phi*P*Phi'+Qd;
		t(cnt+1) = dt*(cnt+2-i);
		std_x(:,cnt+1) = sqrt(diag(P));
		cnt = cnt +1;
	end;
	P = D*P*D' + L*R*L';		% measurement update
	t(cnt+1) = T*(i);
	std_x(:,cnt+1) = sqrt(diag(P));
	cnt = cnt +1;
end;
pos_x = -.4;
pos_y =  .4;
clf;
subplot(311);plot(t,-std_x(1,:)','k',t,std_x(1,:)','k');
Hy=text;
set(Hy,'string','\sigma_p(t), m','units','inches','pos',[pos_x,pos_y-.1]);
set(Hy,'rotat',90);
grid

subplot(312);H=plot(t,-std_x(2,:)','k',t,std_x(2,:)','k');
Hy=text;
set(Hy,'string','\sigma_v(t), m/s','units','inches','pos',[pos_x,pos_y-.2]);
set(Hy,'rotat',90);
grid

subplot(313);H=plot(t,-std_x(3,:)','k',t,std_x(3,:)','k');
%axis([0,N*T,-5,5]);
Hy=text;
set(Hy,'string','\sigma_b(t), m/s^2','units','inches','pos',[pos_x,pos_y-.22]);
set(Hy,'rotat',90);
xlabel('Time, t, seconds')
grid


print -deps ch3_In_INS_est.eps