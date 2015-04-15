% Example Script #1 for kalmanFit()
% This routine will load some variables from mat file and then fit a simple
% state space model on it (without using optionsSpec)
%
% The model of this particular example (in non matrix notation) is:
%
% y(t)  = b_1(t)*x_1(t) + e(t)     
% b_1(t)= u_1 + F_1*b_1(t-1) + v_1(t)     
%
% e(t)  ~ N(0,R)
% v_1(t)~ N(0,Q_1)
%
% where the estimated coefficients are u_1, F_1, R and Q_1

clear;

addpath('m_Files');     

load Example_FEX.mat;   % Load some data (x_1)

%****************************** OPTIONS ***********************************

dep=some_variables(:,1);        % dep is the dependent variable
indep=some_variables(:,3);      % indep is the independent variable (regressors)
                
%**************************************************************************

[specOut]=kalmanFit(dep,indep);   % Fitting function

rmpath('m_Files');