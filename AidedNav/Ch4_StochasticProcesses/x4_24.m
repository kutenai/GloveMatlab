% This function implements Figure 4.5 and Example 4.24 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.

clf

CEP = 1.1774;
R95 = 2.4477;

P = [ 1  3 
      3 16]
corr_coef = P(1,2)/sqrt(P(1,1)*P(2,2))  
[U,S,V]=svd(P)      % P = U*S*V'      
eig(P)
sigma = sqrt(S)
check = U*sigma*sigma*U'

% plot principal axes
v=eye(2,2)*R95;
x=sigma*v;  
w=U*x;

subplot(131)
plot([0;v(1,1)],[0;v(2,1)],'k',[0;v(1,2)],[0;v(2,2)],'k','linewidth',3)
axis([-10,10,-10,10])
axis('square')
xlabel('v_1')
ylabel('v_2')
grid
hold on
subplot(132)
plot([0;x(1,1)],[0;x(2,1)],'k',[0;x(1,2)],[0;x(2,2)],'k','linewidth',3)
axis([-10,10,-10,10])
axis('square')
xlabel('x_1')
ylabel('x_2')
grid
hold on
subplot(133)
plot([0;w(1,1)],[0;w(2,1)],'k',[0;w(1,2)],[0;w(2,2)],'k','linewidth',3)
axis([-10,10,-10,10])
axis('square')
xlabel('w_1')
ylabel('w_2')
grid
hold on


% draw ellipse
N = 100;
theta = 0:pi/(N-1):pi;
for i=1:N,
    v(:,[i,i+N]) = [cos(theta(i)),  cos(theta(i)+pi)
                    sin(theta(i)),  sin(theta(i)+pi)];
    x(:,[i,i+N]) = sigma*v(:,[i,i+N]);
    w(:,[i,i+N]) = U*x(:,[i,i+N]);
end
subplot(131)
plot(v(1,:)*CEP,v(2,:)*CEP,'k',v(1,:)*R95,v(2,:)*R95,'k','linewidth',1.5)    
subplot(132)
plot(x(1,:)*CEP,x(2,:)*CEP,'k',x(1,:)*R95,x(2,:)*R95,'k','linewidth',1.5)    
subplot(133)
plot(w(1,:)*CEP,w(2,:)*CEP,'k',w(1,:)*R95,w(2,:)*R95,'k','linewidth',1.5)    

% scatter plot
M=200
v = randn(2,M);
x = sigma*v;
w = U*x;
count_v = 0;
count_w = 0;

count_v95 = 0;
count_w95 = 0;

Pinv = inv(P);
for i=1:M,
    norm_v = sqrt(v(:,i)'*v(:,i));
    if norm_v<=R95
        count_v95 = count_v95+1;
        if norm_v<=CEP
            count_v = count_v+1;
        end
    end
    norm_w2 = w(:,i)'*Pinv*w(:,i);
    if norm_w2<=R95*R95
        count_w95 = count_w95+1;
        if norm_w2<=CEP*CEP
            count_w = count_w+1;
        end
    end
end

[count_v,count_w,count_v95,count_w95]

subplot(131)
plot(v(1,:)',v(2,:)','.')
hold off
subplot(132)
plot(x(1,:)',x(2,:)','.')
hold off
subplot(133)
plot(w(1,:)',w(2,:)','.')
hold off
                    