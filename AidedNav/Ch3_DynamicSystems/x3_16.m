% This function implements example 3.16 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.

clear
% continuous time system
A=[-2 0;1 0]
B=[1;0]
C=[0 1]
H=C;
D=0

T = 0.1;    % sample period

% compute discrete time equivalent
%[Phi,Gamma] = c2d(A,B,T)
Phi = [0.8187 0
       0.0906 1.00]
Gamma =[0.0906;0.0047]


Q=[H
   H*Phi]
invQ = inv(Q)
p = invQ(:,2)       % last column

invU = [Phi*p,p]
U = inv(invU)

%check
Phi_o = U*Phi*invU
Gamma_o=U*Gamma         % not relevant 
H_o = H*invU
% check
% eig(Phi_o)
% roots([1 -Phi_o(1,1) -Phi_o(2,1)])

poles_des   = [0.9+0.1*j,0.9-0.1*j];
chareqn_des = [1 -(poles_des(1)+poles_des(2)) (poles_des(1)*poles_des(2))];
check_poles = roots(chareqn_des)

a1 = -Phi_o(1,1)
a2 = -Phi_o(2,1)

Lo(1,1) = -(poles_des(1)+poles_des(2)) - a1;
Lo(2,1) = (poles_des(1)*poles_des(2)) - a2

L = invU*Lo

%check 
eig(Phi_o-Lo*H_o)
eig(Phi - L*H)

N=51;
x0 = [10;1];
xh0 = [0;0];
% preallocations
X = zeros(2,N);     X(:,1)=x0;      
Y = zeros(1,N);     Y(1,1)=H*x0;
Xh = zeros(2,N);    Xh(:,1)=xh0;
Yh = zeros(1,N);    Yh(1,1)=H*xh0;
u  = 0;
for i=1:N-1,
    t(i) = T*(i-1);
    Y(:,i) = H*X(:,i);
    X(:,i+1) = Phi*X(:,i)+Gamma*u;

    Yh(:,i) = H*Xh(:,i);
    Xh(:,i+1) = Phi*Xh(:,i)+Gamma*u + L*(Y(i)-Yh(i));
end
i=N;
t(i)   = T*(i-1);
Y(:,i) = H*X(:,i);
Yh(:,i) = H*Xh(:,i);
    
% subplot(221)
% plot(t,Y-Yh,'k')
% grid
% xlabel('Time, t, sec')
% ylabel('Output error, \delta y')
% 
% subplot(223)
% plot(t,Y,'k-',t,Yh,'k--')
% grid
% xlabel('Time, t, sec')
% ylabel('Output, y')

subplot(211)
plot(t,X(1,:)'-Xh(1,:)','k-', t,X(2,:)'-Xh(2,:)','k--')
grid
xlabel('Time, t, sec')
ylabel('State error, \delta x')

subplot(212)
plot(t,X,'k-',t,Xh,'k--')
grid
xlabel('Time, t, sec')
ylabel('State, x')