M = .5;
m = 0.2;
b = 0.1;
i = 0.006;
g = 9.8;
l = 0.3;

p = i*(M+m)+M*m*l^2; %denominator for the A and B matricies
A = [0      1              0           0;
     0 -(i+m*l^2)*b/p  (m^2*g*l^2)/p   0;
     0      0              0           1;
     0 -(m*l*b)/p       m*g*l*(M+m)/p  0]
B = [     0; 
     (i+m*l^2)/p;
          0;
        m*l/p]
C = [1 0 0 0;
     0 0 1 0]
D = [0;
     0]

T=0:0.05:10;
U=0.2*ones(size(T));
[Y,X]=lsim(A,B,C,D,U,T);
plot(T,Y)
axis([0 2 0 100])