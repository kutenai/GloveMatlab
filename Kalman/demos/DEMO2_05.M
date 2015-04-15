%
% Demonstrates power spectral densities of different noise types
%
clear all;
close all;
disp('demo2_06 : Simulate and analyze pseudo-noise types');
noise0(1) = randn;       % unit white gaussian noise
noise1(1) = 128;         % random walk (Wiener process)
noise2(1) = randn;       % exponentially correlated
damping2  = exp(-1/100); % e.c. damping factor
sigma2    = sqrt(1 - damping2^2);
noise3(1) = randn;       % harmonic noise
damping3  = exp(-1/100); % h.n. damping factor
sigma3    = sqrt(1 - damping3^2);
n4        = randn;       % quadrature of noise
delta     = 2*pi/32;     % harmonic noise angular increments
c         = cos(delta);
s         = sin(delta);
for k=2:4098,
   noise0(k) = randn;
   noise1(k) = noise1(k-1) + randn;
   noise2(k) = noise2(k-1)*damping2 + sigma2*randn;
   noise3k   = (c*noise3(k-1) + s*n4)*damping3 + sigma3*randn;
   n4        = (-s*noise3(k-1) + c*n4)*damping3 + sigma3*randn;
   noise3(k) = noise3k;
end;
figure;
subplot(2,1,1),plot(noise0);title('White Gaussian Noise');ylabel('Noise');
p = psd(noise0,2048,64,2048);
subplot(2,1,2),loglog(p);ylabel('PSD');
figure;
subplot(2,1,1),plot(noise1);title('Random Walk');ylabel('Noise');
p = psd(noise1,2048,64,2048);
subplot(2,1,2),loglog(p);ylabel('PSD');
figure;
subplot(2,1,1),plot(noise2);title('Exponentially Correlated Noise');ylabel('Noise');
p = psd(noise2,2048,64,2048);
subplot(2,1,2),loglog(p);ylabel('PSD');
figure;
subplot(2,1,1),plot(noise3);title('Harmonic Noise');ylabel('Noise');
p = psd(noise3,2048,64,2048);
subplot(2,1,2),loglog(p);ylabel('PSD');
