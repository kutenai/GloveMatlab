function [dx]=Euler(u)
ang = u(1:3);
w_bi_b= u(4:6);     % angular rate of body wrt inertial in body

Omga =[1    sin(ang(1))*tan(ang(2))  cos(ang(1))*tan(ang(2))
       0    cos(ang(1))             -sin(ang(1))
       0    sin(ang(1))/cos(ang(2)) cos(ang(1))/cos(ang(2))];
       
dx = Omga*w_bi_b;       
       
