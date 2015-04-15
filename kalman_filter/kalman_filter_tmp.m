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

xna=xa+1*(rand(size(xa))-0.5);

plot(ta,xna,'b-');

xc=[xa(1);
    0;
    0];

F=[1   dt   0;
   0   1    dt;
   0   0    1];

H=[1 0 0];

xca=xc;
nc=2;
k=0.1;
for t=ta(2:end)
    xc=F*xc;
    xc(1)=xc(1)-k*(xc(1)-xna(nc));
    xc(2)=xc(2)-k*(xc(1)-xna(nc));
    xc(3)=xc(3)-k*(xc(1)-xna(nc));
    xca=[xca xc];
    nc=nc+1;
end

hold on;
plot(ta,xca(1,:),'r-','linewidth',2);
xlabel('time, s');
ylabel('x, m');
legend('noised','filtered');
