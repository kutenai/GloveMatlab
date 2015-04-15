% Likelihood/objective function for kalmanFit

function [sumloglik,specOut]=kalmanLik(dep,indep,param,optionsSpec,Coeff,Tag,display)

nc=size(indep,2);

% the next lines will figure out the structure Coeff, which hold the
% coefficients of the model to every call to kalmanLik()

idx_u=[];
idx_F=[];

for j=1:nc

    if strcmp(optionsSpec.u_D{j},'e')
        idx_u(end+1)=j;
    end

    if strcmp(optionsSpec.F_D{j},'e')
        idx_F(end+1)=j;
    end

end

n_u_D=length(idx_u);
n_F_D=length(idx_F);

Tag.F=nonzeros(Tag.F);
Tag.u=nonzeros(Tag.u);

for i=1:n_F_D
    Coeff.F(idx_F(i))=param(Tag.F(i));
end

for i=1:n_u_D
    Coeff.u(idx_u(i))=param(Tag.u(i));
end

[nr,nc]=size(indep);

Coeff.Q=abs(param(end-nc:end-1));
Coeff.R=abs(param(end));

% Some precalculation for beta, n and P

beta{1,1}='t|t-1';  % this is the beta at t conditional on t-1
beta{2,1}='t|t';

n{1,1}='t|t-1';
f{1,1}='t|t-1';

P{1,1}='t|t-1';
P{2,1}='t|t';

% Prealocation of some variables

beta{1,2}=zeros(nr,nc);     % beta at t conditional on t-1
beta{2,2}=zeros(nr,nc);     % beta at t conditional on t

n{1,2}=zeros(nr,1);         % n (residue) at t conditional on t-1
f{1,2}=zeros(nr,1);         % f (variance of y) at t conditional on t-1

P{1,2}=cell(nr,1);          % cell array for P matrix
P{2,2}=cell(nr,1);          % cell array for P matrix

Coeff.F=repmat(Coeff.F,nc,1).*eye(nc);  % just changing from vector to matrix so that the calculations match
Coeff.Q=repmat(Coeff.Q,nc,1).*eye(nc);  % just changing from vector to matrix so that the calculations match

beta{1,2}(1,:)=((eye(nc)-Coeff.F)^(-1)*Coeff.u')';  % unconditional beta for first element of beta
beta{2,2}(1,:)=((eye(nc)-Coeff.F)^(-1)*Coeff.u')';  % unconditional beta for first element of beta

P{1,2}{1}=(eye(nc)-Coeff.F.^2)^(-1)*(Coeff.Q);    % unconditional covariance matrix for first element of P
P{2,2}{1}=(eye(nc)-Coeff.F.^2)^(-1)*(Coeff.Q);    % unconditional covariance matrix for first element of P

% For the case of non invertible (eye(nc)-Coeff.F.^2), the next lines will
% build the first values of the betas vectors and P matrices as naive
% guesses (0 for P and Coeff.u for beta).

if any(any([isnan(P{1,2}{1}) isinf(P{1,2}{1})]))
    
    P{1,2}{1}=zeros(nc);
    P{2,2}{1}=zeros(nc);
    
    beta{1,2}(1,:)=Coeff.u;
    beta{2,2}(1,:)=Coeff.u;
    
end
    

for i=2:nr
    
    % Prediction (page 23 of Kim and Nelson (1999))
     
    beta{1,2}(i,:)=Coeff.u'+Coeff.F*beta{2,2}(i-1,:)';      % beta(t|t-1)
    
    P{1,2}{i}=Coeff.F*P{2,2}{i-1}*Coeff.F'+Coeff.Q;         % P(t|t-1)
    n{1,2}(i,1)=dep(i,1)-indep(i,:)*(beta{1,2}(i,:))';      % n(t|t-1)
    f{1,2}(i,1)=indep(i,:)*P{1,2}{i}*indep(i,:)'+Coeff.R;   % f at t|t-1
    
    % Updating  (page 23 of Kim and Nelson (1999)
    
    K(:,i)=P{1,2}{i}*indep(i,:)'*(f{1,2}(i,1)^-1);          % K(t) - Kalman gain
    beta{2,2}(i,:)=(beta{1,2}(i,:)'+K(:,i)*n{1,2}(i,1))';   % beta(t|t)
    P{2,2}{i}=P{1,2}{i}-K(:,i)*indep(i,:)*P{1,2}{i};        % P(t|t)
   
end

% normal likelihood for whole time period

Lik(:,1)=1./(sqrt(2.*pi().*f{1,2}(:,1))).*exp(-(n{1,2}(:,1).^2)./(2.*f{1,2}(:,1)));

sumloglik=-sum(log(Lik(2:end))); % this the sum of log likelihood (in negative sign since fminsearch minimizes)

% control for inf, nan of imaginary numbers

if isnan(sumloglik)||isreal(sumloglik)==0||isinf(sumloglik)
    sumloglik=inf;
end

% passing variables to Coeff structure

Coeff.P=P;
Coeff.beta=beta;

switch display
    case 1
        disp(['Sum of Log likelihood of State Space Model = ' num2str(-sumloglik)]);
    case 0
end

% Building output

condMean{1,1}='t|t-1';
condMean{2,1}='t|t';

condMean{1,2}=sum(beta{1,2}.*indep,2);
condMean{2,2}=sum(beta{2,2}.*indep,2);

specOut.Coeff=Coeff;
specOut.condMean=condMean;
specOut.LL=-sumloglik;
specOut.nParam=length(param);