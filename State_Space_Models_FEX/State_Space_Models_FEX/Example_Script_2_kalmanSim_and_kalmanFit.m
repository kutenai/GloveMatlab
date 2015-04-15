% Example Script for simulation and fitting of a state space model
%
% This script will first simulate a state space model using kalmanSim.m with 2 regressor and
% then fit it using the fitting function (kalmanFit.m)
% In non matrix notation, the model in this particular example is:
%
% y(t) = b_1(t)*x_1(t) + b_2(t)*x_1(t)+e(t)     
% b_1(t)= .5 + .2*b_1(t-1) + v_1(t)     
% b_2(t)= .4 + .3*b_2(t-1) + v_2(t)   
%
% e(t)  ~ N(0,1)
% v_1(t)~ N(0,.5)
% v_2(t)~ N(0,.3)

clear;
addpath('m_Files');     

%****************************** OPTIONS ***********************************

nr=1000;    % Number of observations

Coeff.u=[.5 .4];    % u coefficient at beta equation
Coeff.F=[.5 .5];    % F coefficient at beta equation
Coeff.Q=[.5 .3];    % variance of residue at beta equation
Coeff.R=1;         % variance of residue at y equation

%**************************************************************************

[simSpec_Out]=kalmanSim(nr,Coeff);   % Simulation Function

dep=simSpec_Out.simSeries;  % passing the simulated series to dep vector
indep=simSpec_Out.indep;    % passing the simulated explanatory series to indep matrix

[specOut]=kalmanFit(dep,indep); % Notes that the function is called in the most simple way, without optionsSpec

rmpath('m_Files');