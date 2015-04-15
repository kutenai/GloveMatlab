function [dat]=ex7_1(t_final)
r2d = 180/pi;
fs = 100;   % Hz
sigma1 = 0.005;
sigma2 = 1*pi/180;
sigma3 = 0.0005;
lambda = 1/300;

T       = 1/fs;
t  = 0:T:t_final;
N  = length(t);

% compute gyro meas noise
n1 = sigma1*randn(N,1);

% compute angle noise 
n2 = sigma2*randn(N,1);

% compute actual angular rate and angle
[w,ang]  = def_w(t);

% compute gyro bias
b = int_b(lambda,sigma3,T,N);

% compute gyro measurement
u = w + b + n1;
% compute angle measurement
size(ang),size(n2)
y = ang + n2;

% compute uncorrected ref traj
[theta]=rate_int(u,T,0,0);

figure(1)
plot(t,w,'k',t,u,'b')
legend('\omega','u')
xlabel('Time, t, sec')
ylabel('\omega, rad/s')

figure(2)
plot(t,b)
xlabel('Time, t, sec')
ylabel('b, rad/s')

figure(3)
plot(t,ang*r2d,'k',t,y*r2d,'b',t,theta*r2d,'g')
legend('\theta','y','est')
xlabel('Time, t, sec')
ylabel('ang, deg')

figure(4)
plot(t,ang*r2d-theta*r2d)
xlabel('Time, t, sec')
ylabel('est err, deg')

save ex7_1.mat u y t b w ang

function [theta]=rate_int(w,T,b,thta0)
% This function was written just to check that the data includes sufficient angle drift 
% to make the problem interesting.
N = length(w);
theta = ones(N,1)*thta0;
for i=2:N-1,
    theta(i) = theta(i-1) + T*(w(i)+w(i-1)-b)/2;
end
    


function [b]=int_b(lambda,sigma3,T,N)

[phi,Qd]=calc_Qd_phi(-lambda,sigma3^2,T);
w = sqrt(Qd)*randn(N,1);
b = zeros(N,1);
b(1) = randn*sigma3; 
for i=2:N,
    b(i) = phi*b(i-1) + w(i);
end




function [w,theta]=def_w(t)
N = length(t);
w = zeros(N,1);
theta = zeros(N,1);
t1 = t(ceil(N/10));
t2 = t(floor(5*N/10));
T = t2-t1;
omga = 2*pi/T;
w(ceil(N/10):floor(5*N/10)) = sin(omga*(t(ceil(N/10):floor(5*N/10))-t1));
w(ceil(6*N/10):floor(8*N/10)) = 0.5;
w(ceil(8*N/10):N) = -0.5;
theta(ceil(N/10):floor(5*N/10)) = (1-cos(2*pi*(t(ceil(N/10):floor(5*N/10))-t1)/T))/omga;
theta(ceil(6*N/10):floor(8*N/10)) = 0.5*(t(ceil(6*N/10):floor(8*N/10)) - t(ceil(6*N/10)));
theta(ceil(8*N/10):N) = -0.5*(t(ceil(8*N/10):N)-t(N));


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