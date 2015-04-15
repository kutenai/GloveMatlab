% The function fix the parameter vector so that the coefficients passed to
% fminsearch are those who the user wants to estimate (the 'e' choices)

function [param0_out,Coeff,Tag]=fixParam(param0,nc,optionsSpec)

Coeff.F=param0(1:nc);
Coeff.u=param0(nc+1:nc+nc);
Coeff.Q=param0(end-nc:end-1);
Coeff.R=param0(end);

idx_u=[];
idx_F=[];

for j=1:nc

    if strcmp(optionsSpec.u_D{j},'e')
        idx_u(end+1)=j;
    else
        Coeff.u(j)=optionsSpec.u_D{j};
    end

    if strcmp(optionsSpec.F_D{j},'e')
        idx_F(end+1)=j;
    else
        Coeff.F(j)=optionsSpec.F_D{j};
    end

end

param0_out2=num2cell(param0);

for j=1:nc

    if strcmp(optionsSpec.F_D{j},'e')==0
        param0_out2{j}='out';
    end

    if strcmp(optionsSpec.u_D{j},'e')==0
        param0_out2{nc+j}='out';
    end

end

param0_out=[];
for i=1:length(param0_out2)
    
    if ischar(param0_out2{i})==0;
        param0_out(end+1)=param0_out2{i};
    end
    
end

Tag.u=[];
Tag.F=[];

for i=1:nc
    
    idx_u=find(Coeff.u(i)==param0_out);
    
    if isempty(idx_u)==0
        Tag.u(i)=idx_u(1);
    end
    
    idx_F=find(Coeff.F(i)==param0_out);
    
    if isempty(idx_F)==0
        Tag.F(i)=idx_F(1);    
    end
        
end


        
        
        
        
    
    
