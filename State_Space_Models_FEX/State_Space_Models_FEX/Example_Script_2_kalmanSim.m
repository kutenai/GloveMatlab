% Example Script for simulation of a state space model with 2 dependent
% variable
% In non matrix notation, the model simulated in this particular example is:

% y(t) = b_1(t)*x_1(t) + b_2(t)*x_2(t)+e(t)     
% b_1(t)= .5 + .1*b_1(t-1) + v_1(t)     
% b_2(t)= .3 + .4*b_2(t-1) + v_2(t)
%
% e(t)  ~ N(0,.1)
% v_1(t)~ N(0,.5)
% v_2(t)~ N(0,.2)

clear;
addpath('m_Files');     

%****************************** OPTIONS ***********************************

nr=500;    % Number of observations

% The Coeff structure stores the coefficinets of the model. Each collumn
% means each independent variable. 

Coeff.u=[.5 .3];    % u coefficient at beta equation (you can increase as wanted)
Coeff.F=[.1 .4];    % F coefficient at beta equation (you can increase as wanted)
Coeff.Q=[.5 .2];    % variance of residue at beta equation (you can increase as wanted)
Coeff.R=.1;         % variance of residue at y equation

%**************************************************************************

[simSpec_Out]=kalmanSim(nr,Coeff);   % Simulation Function

rmpath('m_Files');