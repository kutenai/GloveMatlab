v0=4;
a=-1;
dt=0.01;
tm=10;
x=0;
v=v0;
xa=x;
va=v;
ta=0:dt:tm;
for t=ta(2:end)
    x=x+dt*v;
    v=v+dt*a;
    xa=[xa x];
    va=[va v];
end

sig=1;

xna=xa+sig*randn(size(xa));

plot(ta,xna,'b-');

xc=[xa(1);
    0;
    0];  % estimation

F=[1   dt   0;
   0   1    dt;
   0   0    1];

H=[1 0 0];

P=eye(3);

I=eye(3);

R=sig^2;  % covariance matrix for gaussian distribution

xca=xc;
nc=2;
k=0.1;
for t=ta(2:end)
    Ps=F*P*F';
    K=Ps*H'*(H*Ps*H'+R)^(-1);
    xc=F*xc+K*(xa(nc)-H*F*xc);
    %P=(I-K)*Ps*(I-K)'+K*R*K';
    P=(I-K*H)*Ps;
    xca=[xca xc];
    nc=nc+1;
end

hold on;
plot(ta,xca(1,:),'r-','linewidth',2);
% plot(ta,xca(2,:),'r-','linewidth',2);
% plot(ta,va,'b-');
xlabel('time, s');
ylabel('x, m');
legend('noised','filtered');
