%
% Demonstrating matrix exponential function
%
disp('Exponentials of randomly generated matrices N = expm(M)');
for n =1:6,
   M = randn(n)
   N = expm(M)
end;
disp('Exponential of scaled shift matrix');
n = 6;
s = 1/10;
M = zeros(n);
for k=2:n,
   M(k-1,k) = s;
end;
M
expm(M)