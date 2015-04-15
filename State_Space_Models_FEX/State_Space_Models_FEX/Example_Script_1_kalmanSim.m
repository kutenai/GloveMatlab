% Example Script for simulation of a state space model with 1 dependent
% variable
% In non matrix notation, the model simulated in this particular example is:
%
% y(t) = b_1(t)*x_1(t) + e(t)     
% b_1(t)= .5 + .1*b_1(t-1) + v_1(t)     
%
% e(t)  ~ N(0,.1)
% v_1(t)~ N(0,.5)

clear;
addpath('m_Files');     

%****************************** OPTIONS ***********************************

nr=500;    % Number of observations

Coeff.u=.5;     % u coefficient at beta equation
Coeff.F=.1;     % F coefficient at beta equation
Coeff.Q=.5;     % variance of residue at beta equation
Coeff.R=.1;     % variance of residue at y equation

%**************************************************************************

[simSpec_Out]=kalmanSim(nr,Coeff);   % Simulation Function

rmpath('m_Files');