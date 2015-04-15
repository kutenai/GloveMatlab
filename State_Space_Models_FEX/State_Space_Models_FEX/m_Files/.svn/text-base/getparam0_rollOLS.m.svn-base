% Function for computing first initial parameters of state space model
% based on rolling windows regressions

% The intuition behind it is that the rolling regression should have a lot
% more noise than the true model (the state space), therefore most of the
% coefficients are computed as 50% of the ones from the OLS approach

function [param0]=getparam0_rollOLS(dep,indep)

[nr,nc]=size(indep);

ols_full=regress(dep,indep);
Coeff.R=.5*sum( (dep-indep*ols_full).^2)/nr;

window=3;

for i=1:nr-window

    ols_param(i,:)=regress(dep(i:window+i-1),indep(i:window+i-1,:));

end

for i=1:nc

    param_dep=ols_param(:,i)-mean(ols_param(:,i));

    AR_param=regress(param_dep(2:end),param_dep(1:end-1));

    Coeff.u(i)=mean(ols_param(:,i));
    Coeff.F(i)=.5*AR_param(1);

    Coeff.Q(i)=(.5*std(ols_param(:,i)))^2;

end

param0(1,1:nc)=Coeff.F;
param0(1,nc+1:nc+nc)=Coeff.u;
param0(1,nc+nc+1:nc+nc+nc)=Coeff.Q;
param0(1,nc+nc+nc+1)=Coeff.R;

