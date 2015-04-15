function []=plot_ahrs_out(t_1,t_2)
% This function plots the data that results from the AHRS dmu sim
% in Chapter 10 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% users/developers risk.

load AHRS.mat   % output of the .mdl sim

t   = ahrs_out(1,:);
[dum,i1]=min(abs(t-t_1));
[dum,i2]=min(abs(t-t_2));
t   = t(i1:i2);
b   = ahrs_out(2:5,i1:i2);     % quaternion
xg  = ahrs_out(6:8,i1:i2);     % gyro bias
ai  = ahrs_out(9,i1:i2);       % stationary indicator
Pr1 = sqrt(ahrs_out(10,i1:i2));      % std for res1
Pr2 = sqrt(ahrs_out(11,i1:i2));      % std for res1
roll_g = ahrs_out(12,i1:i2);   % roll est from gyro integration
roll_a = ahrs_out(13,i1:i2);   % roll est from accelerometer
ptch_g = ahrs_out(14,i1:i2);   % pitch est from gyro integration
ptch_a = ahrs_out(15,i1:i2);   % pitch est from accelerometer
res    = ahrs_out(16:17,i1:i2);   % residuals

clear ahrs_out

load dmu.mat    % input to the .mdl sim

tm   = dmu(1,:);
[dum,i1]=min(abs(tm-t_1));
[dum,i2]=min(abs(tm-t_2));
tm   = tm(i1:i2);
gyro = dmu(2:4,i1:i2);
accl = dmu(5:7,i1:i2);

clear dmu

r2d = 180/pi;

i=1;
figure(i)
clf
subplot(311)
plot(tm,gyro(1,:)*r2d,'k','linewidth',1.0);
ylabel('Ang. rate, p, dps');
axis([min(tm),max(tm),-100,100])
grid
subplot(312)
plot(tm,gyro(2,:)*r2d,'k','linewidth',1.0);
ylabel('Ang. rate, q, dps');
axis([min(tm),max(tm),-100,100])
grid
subplot(313)
plot(tm,gyro(3,:)*r2d,'k','linewidth',1.0);
ylabel('Ang. rate, r, dps');
axis([min(tm),max(tm),-100,100])
grid
xlabel('Time, t, s.')

i=i+1;
figure(i)
clf
subplot(311)
plot(tm,accl(1,:),'k','linewidth',1.0);
ylabel('Accel., u, m/s^2');
axis('tight')
%axis([min(tm),max(tm),-10.2,10.2])
grid
subplot(312)
plot(tm,accl(2,:),'k','linewidth',1.0);
ylabel('Accel., v, m/s^2');
axis('tight')
%axis([min(tm),max(tm),-10.2,10.2])
grid
subplot(313)
plot(tm,accl(3,:),'k','linewidth',1.0);
ylabel('Accel., w, m/s^2');
axis('tight')
%axis([min(tm),max(tm),-10.2,10.2])
grid
xlabel('Time, t, s.')

i=i+1;
figure(i)
clf
subplot(211)
plot(t,res(1,:),'k',t,[Pr1',-Pr1'],'k--');
ylabel('res_1, m/s^2');
axis('tight')
subplot(212)
plot(t,res(2,:),'k',t,[Pr2',-Pr2'],'k--');
ylabel('res_2, m/s^2');
axis('tight')
xlabel('Time, t, s.')

i=i+1;
figure(i)
clf
subplot(211)
plot(t,roll_g'*r2d,'k-',t,ptch_g'*r2d,'k--','linewidth',1.2);
ylabel('Attitude (ARHS), deg');
axis('tight')
grid
subplot(212)
plot(t,roll_a'*r2d,'k-',t,ptch_a'*r2d,'k--','linewidth',1.2);
ylabel('Attitude (accel.), deg');
axis('tight')
grid
xlabel('Time, t, s.')

i=i+1;
figure(i)
clf
plot(t,ai);
ylabel('Stat. Ind.');
axis([min(t),max(t),0,1.2])
xlabel('Time, t, s.')




i=i+1;
figure(i)
clf
subplot(413)
plot(t,res(1,:),'k',t,[Pr1',-Pr1'],'k--');
ylabel('res_1, m/s^2');
%axis('tight')
axis([t_1,t_2,-0.5,0.5])
grid

subplot(414)
plot(t,res(2,:),'k',t,[Pr2',-Pr2'],'k--');
ylabel('res_2, m/s^2');
%axis('tight')
axis([t_1,t_2,-0.5,0.5])
xlabel('Time, t, s.')
grid

subplot(412)
plot(t,roll_g'*r2d,'k-',t,ptch_g'*r2d,'k--','linewidth',1.2);
ylabel('Attitude (ARHS), deg');
axis('tight')
grid

subplot(411)
plot(t,ai,'k');
ylabel('Stat. Ind.');
axis([min(t),max(t),0,1.2])

mean(roll_g)*r2d
std(roll_g)*r2d
mean(ptch_g)*r2d
std(ptch_g)*r2d
% b   = ahrs_out(2:5,i1:i2);     % quaternion
% xg  = ahrs_out(6:8,i1:i2);     % gyro bias
% ai  = ahrs_out(9,i1:i2);       % stationary indicator
