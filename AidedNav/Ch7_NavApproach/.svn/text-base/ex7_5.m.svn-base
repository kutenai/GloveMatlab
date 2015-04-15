function [dat]=ex7_5(t_final)
fs = 100;   % Hz
sigma1 = 0.05;
sigma_b = 0.01/300;
lambda_b = 1/600;
sigma_p  = 1;

T       = 1/fs;
t  = 0:T:t_final;
N  = length(t);
M  = floor(t_final);    % 1 less than the number of pos meas.

% compute accel meas noise
n1 = sigma1*randn(N,1);

% compute position meas noise 
n2 = sigma_p*randn(M+1,1);

% compute actual p,v,a
[p,v,a]  = def_traj(t);

% compute accel bias
b = int_b(lambda_b,sigma_b,T,N);
% 
% compute accel measurement
u = a + b + n1;
% compute pos measurement
k = [(0:M-1)*fs+1,N];
ty = t(k);
y = p(k) + n2;

% compute uncorrected ref traj
[pn,vn]=nav_int(u,T,0,0,0);

figure(1)
plot(t,a,'k',t,u,'b')
legend('accel','u')
xlabel('Time, t, sec')
ylabel('accel, m/s^2')

figure(2)
plot(t,b)
xlabel('Time, t, sec')
ylabel('b, rad/s')

figure(3)
subplot(211)
plot(t,p,ty,y,'x',t,pn,'g')
legend('pos.','pos. meas.')
xlabel('Time, t, sec')
ylabel('Pos, m')
subplot(212)
plot(t,v,t,vn,'g')
legend('vel')
xlabel('Time, t, sec')
ylabel('Vel, m/s')

figure(4)
subplot(211)
plot(t,p-pn)
xlabel('Time, t, sec')
ylabel('pos. est err, m')
subplot(212)
plot(t,v-vn)
xlabel('Time, t, sec')
ylabel('vel. est. err., m/s')

save ex7_5.mat u y t b p v a ty

function [p,v]=nav_int(u,T,b,p0,v0)
% This function was written just to check that the data includes sufficient  drift 
% to make the problem interesting.
N = length(u);
p = ones(N,1)*p0;
v = ones(N,1)*v0;
for i=2:N,
    v(i) = v(i-1) + T*(u(i)+u(i-1)-2*b)/2;
    p(i) = p(i-1) + T*(v(i)) ;
end



function [b]=int_b(lambda,sigma3,T,N)

[phi,Qd]=calc_Qd_phi(-lambda,sigma3^2,T);
w = sqrt(Qd)*randn(N,1);
b = zeros(N,1);
b(1) = randn*sigma3; 
for i=2:N,
    b(i) = phi*b(i-1) + w(i);
end




function [p,v,a]=def_traj(t)
N = length(t);
p = zeros(N,1);
v = zeros(N,1);
a = zeros(N,1);
theta = zeros(N,1);
t1 = t(ceil(N/10));
t2 = t(floor(5*N/10));
T = t2-t1;
omga = 2*pi/T;
A = 2*pi/omga^2
amp = 4*A/T^2
tt = t(ceil(N/10):floor(5*N/10))-t1;
a(ceil(N/10):floor(5*N/10)) = sin(omga*(tt));
a(ceil(6*N/10):floor(8*N/10)) = -amp;
a(ceil(8*N/10):N) = amp;

[p,v]=nav_int(a,t(2)-t(1),0,0,0);

% v(ceil(N/10):floor(5*N/10)) = (1-cos(omga*tt))/omga;
% t2 = t(ceil(6*N/10):floor(8*N/10)) - t(ceil(6*N/10));
% v(ceil(6*N/10):floor(8*N/10)) = -amp*t2;
% t3 = t(ceil(8*N/10):N)-t(ceil(8*N/10));
% v(ceil(8*N/10):N) = v(floor(8*N/10)) + amp*(t3);
% 
% p(ceil(N/10):floor(5*N/10)) = (tt-sin(omga*tt)/omga)/omga;
% p(ceil(5*N/10):floor(6*N/10)) = p(floor(5*N/10));
% p(ceil(6*N/10):floor(8*N/10)) = p(floor(6*N/10)) - amp*(t2.*t2/2);
% p(ceil(8*N/10):N)             = p(floor(8*N/10)) + amp*(t3.*t3/2) + v(floor(8*N/10))*t3;


function [phi,Qd]=calc_Qd_phi(F,Q,Ts)
%
%	F the continuous time state transition matrix
%	Q the continuous time process noise covariance matrix
%	Ts the time step duration
%
%	phi the discrete time transition matrix
%	Qd the equivalent discrete time driving noise
%

[n,m] = size(F);
if n~=m,
	error('In calc_Qd_phi, the F matrix must be square');
end	%if

chi = [ -F      Q
		 0*eye(n) F']*Ts;
gamma=expm(chi);

phi = gamma((n+1):(2*n),(n+1):(2*n))';
Qd  = phi*gamma(1:n,(n+1):(2*n));