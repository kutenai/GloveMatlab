% Function for Simulation of a State Space Model
% 
% INPUT: 
%       nr - number of observations to be simulated
%       Coeff - Coefficients of the model (check Example_1_Script_Sim for
%       instructions of how to use this input)
% 
% OUTPUT:
%       simSpec_Out - A structure with the simulated state space series
%       and also the simulated regressors
%
% Author: Marcelo Perlin
% Email: marceloperlin@gmail.com
% PhD Student at ICMA/Reading University

function [simSpec_Out]=kalmanSim(nr,Coeff)

if nr<0
    error('The number of observations should be an integer positive');
end

if any([size(Coeff.F,2)~=size(Coeff.u,2) size(Coeff.Q,2)~=size(Coeff.F,2)])
    error('The size of Coeff.F, Coeff.u and Coeff.F should be the same')
end

if length(Coeff.R)~=1
    error('The input Coeff.R should have one row and one column')
end

nIndep=size(Coeff.F,2); % the variable Coeff.F controls for how many variables to simulate as independent

% Prealocation of beta

beta=zeros(nr,nIndep);  

% Calculation of regressors (independent variables)

indep=rand(nr,nIndep);

beta(1,:)=Coeff.u; % First value for beta vector

for i=2:nr

    % See page 19 of Kim and Nelson (1999), Equaiton 3.1 and 3.2
    
    beta(i,:)=Coeff.u+ Coeff.F.*beta(i-1,:)+randn(1,nIndep).*sqrt(Coeff.Q); % mean equation of y
    simSeries(i,1)=beta(i,:)*indep(i,:)'+randn(1,1)*sqrt(Coeff.R);          % beta equation

end

% Passing values to output

simSpec_Out.simSeries=simSeries;
simSpec_Out.indep=indep;

plot(simSeries);
xlabel('Time');
ylabel('Simulated Series');