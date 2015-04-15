% Example Script #3 for kalmanFit()
%
% This routine will load some variables from mat file and then fit a 
% state space model considering options feeded to the algorithm.
%
% The model of this particular example (in non matrix notation) is:
%
% y(t) = b_1(t)*x_1(t) + b_2(t)*x_2(t)+e(t)     
% b_1(t)= 0 + F_1*b_1(t-1) + v_1(t)     
% b_2(t)= u_2 + b_2(t-1) + v_2(t)
%
% e(t)~N(0,R)
% v_1(t)~N(0,Q_1)
% v_2(t)~N(0,Q_2)
%
% where the estimated coefficients are F_1, u_2, R, Q_1 and Q_2

clear;

addpath('m_Files');     

load Example_FEX.mat;   % Load some data (x_1 and x_2)

%****************************** OPTIONS ***********************************

dep=some_variables(:,1);        % dep is the dependent variable
indep=some_variables(:,2:3);    % indep is the independent matrix (regressors)

% The next options controls for the state space model specification. 

% The u_D cell controls for where (which indep column to include the u
% parameter). Write 'e' at i positions for estimate coefficient u at
% regressor i (same order as indep) and 0 otherwise.

% The u_F cell controls for where (which indep column to include the F
% parameter). Write 'e' at i positions for estimate coefficient F_i at
% regressor i (same order as indep). Write 1 if you want a random walk
% process and 0 if you don't want F coefficient at all.
% Both cell arrays should have the same number of elements as the number of
% columns at indep

optionsSpec.u_D={ 0  'e'};      % either 0 or 'e' ('e' is the "estimate" tag) 
optionsSpec.F_D={'e'  1 };      % either 1, 0 or 'e' ('e' is the "estimate" tag) 

%**************************************************************************

[specOut]=kalmanFit(dep,indep,optionsSpec);   % Fitting function

rmpath('m_Files');