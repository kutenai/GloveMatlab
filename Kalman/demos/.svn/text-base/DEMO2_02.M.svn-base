%
% Demonstrates relative performance of Wiener filter (fixed-gain)
% and Kalman filter (time-varying gain) on random walk estimation
%
% Applied to random walk process with gaussian sampling noise
%
clear all;
close all;
N = 50;  % Number of samples of process used in simulations
Q = .01; % Variance of random walk increments
R = 1;   % Variance of sampling noise
sigw  = sqrt(Q); % Standard deviations
sigv  = sqrt(R);
%
% Wiener (fixed) gain
%
W = (Q+(Q*(Q+4*R))^(1/2))/(Q+(Q*(Q+4*R))^(1/2)+2*R); 
%
P        = 100;           % Covariance of initial uncertainty
xbar(1)  = sqrt(P)*randn; % Initial value of true process
xhatW(1) = 0;             % Initial estimate of true process using Wiender gain
xhatK(1) = 0;             % Initial estimate of true process using Kalman gain
t(1)     = 0;
rms(1)   = sqrt(P);
%
% Simulation loop
%
for k=2:N;
   t(k)     = k-1;
   xbar(k)  = xbar(k-1) + sigw*randn;          % Random walk
   z(k)     = xbar(k) + sigv*randn;            % Noisy sample
   xhatW(k) = xhatW(k-1) + W*(z(k) - xhatW(k-1)); % Wiener filter estimate
   P        = P + Q;
   K        = P/(P+R);
   xhatK(k) = xhatK(k-1) + K*(z(k) - xhatK(k-1)); % Kalman filter estimate
   P        = P - K*P;
   rms(k)   = sqrt(P);                         % RMS uncdrtainty
end;
%
% Done simulating
%
plot(t,xbar,'b-',t,xhatW,'g-.',t,xhatK,'r--',t,xhatK+rms,'r:',t,xhatK-rms,'r:');
legend('True','Wiener','Kalman','Kalman+Uncert.','Kalman-Uncert.');
title('DEMO #2: Kalman Filter versus Wiener Filter');
xlabel('Discrete Time');
ylabel('Random Walk');


