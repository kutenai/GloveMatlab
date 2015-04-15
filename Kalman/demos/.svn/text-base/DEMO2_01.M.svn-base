%
% Demonstrates performance of a fixed-gain estimator as a function of gain
%
% Applied to random walk process with gaussian sampling noise
%
clear all;
close all;
N     = 1000; % Number of samples of process used in simulations
mse   = .004; % Mean squared Wiener filter error
%               (used in determining process noise)
%
% Four cases
%
R     = [.04,.02,.01,.005];    % Variance of sampling noise
for n=1:4,
   sigv  = sqrt(R(n));         % Standard Deviation of sampling noise
   Q  = mse^2/(R(n) - mse);    % Variance of random walk increments
   sigw  = sqrt(Q);            % Standard Deviation of random walk increments
   %
   % W is Wiener gain (steady state Kalman gain)
   %
   W     = (Q+(Q*(Q+4*R(n)))^(1/2))/(Q+(Q*(Q+4*R(n)))^(1/2)+2*R(n));
   %
   % Eleven values of weighting "w"
   %
   xbar  = 0;          % Initial value of true process
   for m=1:11,
      xhat(m) = xbar; % Eleven filters
      rms(m)  = 0;    % Squared filter errors (initialization)
      if m==6
         w(m) = W;    % Wiener gain
      elseif m<6
         w(m) = (m/6)*W;
      else
         w(m) = W + (1-W)*(m-6)/5;
      end;
   end;
   %
   % Simulation loop
   %
   for k=1:N;
      xbar  = xbar + sigw*randn;  % Random walk
      z     = xbar + sigv*randn;  % Noisy sample
      for m=1:11,
         xhat(m) = xhat(m) + w(m)*(z - xhat(m)); % Filtered estimates
         rms(m)  = rms(m) + (xhat(m) - xbar)^2;  % Sum of estimation errors
      end;
   end;
   %
   % Done simulating
   %
   for m=1:11,
      rms(m) = sqrt(rms(m)/N);   % Root-mean-squared esitmation errors
   end;
   plot(w,rms);
   title('DEMO #1: RMS Filter Error versus Weight (w) --- Four Cases');
   xlabel('Filter weight (w)');
   ylabel('RMS Estimation Error');
   text(W-.015,min(rms),'W');
   hold on;
end;


