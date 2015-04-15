% Example Script #2 for kalmanFit()
%
% This routine will load some variables from mat file and then fit a simple
% state space model on it (without using optionsSpec)
% The model of this particular example (in non matrix notation) is:
%
% y(t)  = b_1(t)*x_1(t) + b_2*x_2 + e(t)     
% b_1(t)= u_1 + F_1*b_1(t-1) + v_1(t)     
% b_2(t)= u_2 + F_2*b_2(t-1) + v_2(t)
%
% e(t)~N(0,R)
% v_1(t)~N(0,Q_1)
% v_2(t)~N(0,Q_2)
%
% where the estimated coefficients are u_1, u_2, F_1, F_2, R, Q_1 and Q_2

clear;

addpath('m_Files');     

load Example_FEX.mat;   % Load some data (x_1 and x_2)

%****************************** OPTIONS ***********************************

dep=some_variables(:,1);        % dep is the dependent variable
indep=some_variables(:,2:3);    % indep is the independent matrix (regressors)

%**************************************************************************

[specOut]=kalmanFit(dep,indep);   % Fitting function

rmpath('m_Files');