clear
g=9.8;  % m/s/s
R=6e6;  % m
H = [1 0 0];
Ry = 3^2;
A = [0 1   0
     0 0  -g
     0 1/R 0];
dt = 10; % sec
phi = expm(A*dt);
Tf = 3600;  % sec
t  = 1:dt:Tf;
N  = Tf/dt;
x = zeros(3,N);
x(:,1) = [0,1,0]
for i=1:N-1,
    y(i,1)   = H*x(:,i);
    x(:,i+1) = phi*x(:,i);
end
y(i+1,1)     = H*x(:,i+1);
ym           = y + Ry*rand(size(y));
subplot(411)
plot(t,ym)
ylabel('pos. meas., m')
subplot(412)
plot(t,x(1,:))
ylabel('pos.')
subplot(413)
plot(t,x(2,:))
ylabel('vel.')
subplot(414)
plot(t,x(3,:)*180/pi)
ylabel('angl., deg')
xlabel('Time, t, sec')
 
save x3_7.mat ym t
