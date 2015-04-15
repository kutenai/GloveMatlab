% Function for Estimation of a state space model by means of kalman filter
%
% INPUT:
%       dep - dependent variable
%
%       indep - independent variable with regressor (aka independent
%       variables)
%
%       optionsSpec - (optional, default='e'). A options structure for defining your own state space
%       model. Please check the pdf document in the zip file for instruction of
%       how to use it. The script Example_Script_3_kalmanFit.m also shows
%       that.
%
% OUTPUT:
%       specOut - A sctructure with the coefficients, final log likelihood,
%       latent variables, among other things.
%
% Author: Marcelo Perlin
% Email: marceloperlin@gmail.com
% PhD Student at ICMA/Reading University

function [specOut]=kalmanFit(dep,indep,optionsSpec)

[nc]=size(indep,2); % nc is the number of regressors

% Some arg checking

if nargin==2

    optionsSpec.u_D ={};
    optionsSpec.F_D ={};
    for i=1:nc
        optionsSpec.u_D{i}='e';
        optionsSpec.F_D{i}='e';
    end
end

if any([iscell(optionsSpec.u_D)==0 iscell(optionsSpec.F_D)==0])
    error('The inputs optionsSpec.u_F and optionsSpec.u_D should be cell arrays');
end


if any([size(indep,2)~=length(optionsSpec.u_D) size(indep,2)~=length(optionsSpec.F_D)])
    error('The vectors  optionsSpec.u_F and optionsSpec.u_D should have the same number of columns as the indep matrix');
end

if size(dep,1)~=size(indep,1)
    error('The indep and dep should have the same size of rows');
end

% Some more arg checking for inputs

for i=1:length(optionsSpec.u_D)
    if optionsSpec.u_D{i}==0
        continue;
    elseif strmatch(optionsSpec.u_D{i},'e')
        continue;
    else
        error('The optionsSpec.u_D cell should have either ''e'' or 0');
    end
end


for i=1:length(optionsSpec.F_D)
    if any([optionsSpec.F_D{i}==0 optionsSpec.F_D{i}==1])
        continue;
    elseif strmatch(optionsSpec.F_D{i},'e')
        continue;
    else
        error('The optionsSpec.u_F cell should have either ''e'', 0 or 1');
    end
end

fprintf(1,'\n***** Estimation of State Space Model (Kalman Filter) *****\n\n');

warning('off');

% The getParam0_rollOLS will find the starting coefficients by running
% rolling regressions and then getting an estimate of the variances and the
% parameter of the beta equation

[param0]=getparam0_rollOLS(dep,indep);

% the fixParam function fix the parameter so that fminsearch only find the
% coefficients tagged with 'e'

[param0,Coeff,Tag]=fixParam(param0,nc,optionsSpec);

% find maximum likelihood with fminsearch

[param]=fminsearch(@(param)kalmanLik(dep,indep,param,optionsSpec,Coeff,Tag,1),param0);

% Filter it through data in order to get latent variables

[arg1,specOut]=kalmanLik(dep,indep,param,optionsSpec,Coeff,Tag,0);

% Output for screen

fprintf(1,'\n\n**** Optimization Finished ****\n\n');

fprintf(1,['Final sum of log likelihood = ' num2str(specOut.LL)]);
fprintf(1,['\nNumber of Estimated parameters = ' num2str(specOut.nParam)]);

fprintf(1,'\n\n--> Final Parameters <--\n');

for i=1:nc

    fprintf(1,['\nCoefficients for Column ' num2str(i) ' at indep:\n\n']);
    fprintf(1,['Value of u_' num2str(i) ': ' num2str(specOut.Coeff.u(i)) '\n']);
    fprintf(1,['Value of F_' num2str(i) ': ' num2str(specOut.Coeff.F(i,i)) '\n']);
    fprintf(1,['Value of Q_' num2str(i) ': ' num2str(specOut.Coeff.Q(i,i)) '\n']);

end

fprintf(1,['\nValue of R: ' num2str(specOut.Coeff.R) '\n']);

plot([specOut.condMean{1,2}, dep]);
legend('Fitted Series (t|t-1)','Real Series');
xlabel('Time');
ylabel('Series');

warning('on');