%
% "Type 2 Tracker" for random walk process with mean velocity
%
clear all;
close all;
N      =  100; % Number of samples of process used in simulations
R      = .16;  % Variance of sampling noise
Q0     = .01;
V      = .1;
Q1     = Q0 + V^2;     % Variance for Type 1 Tracker
P      = [Q0,0;0,Q1];  % Covariance for Type 2 Tracker
sigv   = sqrt(R);      % Standard Deviation of sampling noise
sigw   = sqrt(Q0);     % Standard Deviation of random walk increments
%
% Wiener gain for Type 1 tracker
%
W      = (Q1+(Q1*(Q1+4*R))^(1/2))/(Q1+(Q1*(Q1+4*R))^(1/2)+2*R);
xbar   = 0;           % True value of signal
x1hat  = 0;           % Initial estimate for Type 1 Tracker
x2hat  = [0;V];       % Initial estimate for Type 2 Tracker
H      = [1,0];       % Measurement sensitivity for Type 2 Tracker
Phi    = [1,1;0,1];   % State transition for Type 2 Tracker
%
% Simulation loop
%
for k=1:N;
   xbar  = xbar + V + sigw*randn;  % Random walk plus constant drift rate
   z     = xbar + sigv*randn;      % Noisy sample
   x1hat = x1hat + W*(z - x1hat);  % Type 1 Tracker
   x2hat = Phi*x2hat;              % Predicted position
   P     = Phi*P*Phi' + [Q0,0;0,0];% Covariance of prediction unceretainty
   K     = P*H'/(H*P*H'+R);        % Kalman gain
   x2hat = x2hat + K*(z - H*x2hat);% Corrected position estimate
   P     = P - K*H*P;              % Covariance of corrected uncertainty
   P     = .5*(P+P');              % (Trick to maintain symmetry)
   t0(k) = xbar;
   t1(k) = x1hat;
   t2(k) = x2hat(1);
   t(k)  = k;
end;
%
% Done simulating
%
plot(t,t0,'b-',t,t1,'g:',t,t2,'r--');
legend('True','Type 1','Type 2');
title('DEMO #3: Type 1 Tracker versus Type 2 Tracker');
xlabel('Discrete Time');
ylabel('Position Estimate');


