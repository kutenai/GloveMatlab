%
% Demonstrates relative performance of Kalman filter
% and Rauch-Tung-Striebel smoother on random walk estimation
%
clear all;
close all;
N = 100;  % Number of samples of process used in simulations
Q = .01;  % Variance of random walk increments
R = 1;    % Variance of sampling noise
sigw  = sqrt(Q); % Standard deviations
sigv  = sqrt(R);
%
%
Ppred      = 100;           % Covariance of initial uncertainty
xbar(1)    = sqrt(Ppred)*randn; % Initial value of true process
xpred(1)   = 0;             % Initial (predicted) value of true process
sawtooth   = sqrt(Ppred);
ts         = 0;
%
% Forward pass: filter
%
for k=1:N;
   t(k)     = k-1;
   if k~=1
      xbar(k)  = xbar(k-1) + sigw*randn;       % Random walk
      Ppred(k) = Pcorr(k-1) + Q;
      sawtooth = [sawtooth,sqrt(Ppred(k))];
      ts       = [ts,t(k)];
      xpred(k) = xcorr(k-1);
   end;
   z(k)     = xbar(k) + sigv*randn;            % Noisy sample
   K        = Ppred(k)/(Ppred(k)+R);
   xcorr(k) = xpred(k) + K*(z(k) - xpred(k));  % Kalman filter estimate
   Pcorr(k) = Ppred(k) - K*Ppred(k);
   sawtooth = [sawtooth,sqrt(Pcorr(k))];
   ts       = [ts,t(k)];
end;
%
% Backward pass: smooth
%
xsmooth = xcorr;
for k=N-1:-1:1,
   A          = Pcorr(k)/Ppred(k+1);
   xsmooth(k) = xsmooth(k) + A*(xsmooth(k+1) - xpred(k+1));
end;
plot(t,xbar,'b-',t,xpred,'g:',t,xcorr,'k-.',t,xsmooth,'r--');
legend('True','Predicted','Corrected','Smoothed');
title('DEMO #7: Kalman Filter versus Rauch-Tung-Striebel Smoother');
xlabel('Discrete Time');
ylabel('Random Walk');
figure;
semilogy(ts,sawtooth);
xlabel('Discrete Time');
ylabel('RMS Estimation Uncertainty');
title('''Sawtooth Curve''');


