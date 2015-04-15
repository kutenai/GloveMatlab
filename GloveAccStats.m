function adata = GloveAccStats( varargin )
%GloveStats Calculate integration variance and std dev
% Read files from the directory specified. The direcory is assumed to
% contain files numbered *1 to *N. Each file is a 1 minute or 30 second
% capture of glove data with no or minimal motion. This funcion will
% integrate the gyro and accelerometer data at 30 second and 1 minute
% intervals, and capture all of those statistics. Then, the integration
% statistics will be calculated for all of the 30 second and 1 minute
% values.

    
    T = 0.01;

    files = dirc([fdir '/*.mat'],'f','n');
    
    nFiles = size(files,1);

    g = GloveData;
    
    adata = struct();
    
    skip = 100;
    rows = size(files,1);
    
    % Velocity, integral of acceleration
    adata.vfull = zeros(rows,18);
    adata,vhalf = zeros(rows*2,18);
    
    for k = 1:size(files,1)
        f = files(k);
        t = load([fdir '/' f{1}]);
        % Some of the newer structures include a .Name and a .T
        % value. .Name specifies the name directly, older structures
        % just had the first field be the data.. I could not specify
        % anyting else, like the period.
        if isfield(t,'Data')
            data = t.Data;
        else
            fn = fieldnames(t);
            field = fn{1};
            data = getfield(t,field);
        end
        
        if isfield(t,'T')
            T = t.T;
        else
            % This is the default for old data that did not specify
            % otherwise
            T = 1/180;
        end

        acc = data(skip+1:size(data,1),g.accIndexes)*g.accFactor*9.8;
        drows = size(acc,1);
        
        % Integrate the accelerometer data for 30 seconds and for 1 minute
        
        adata.vfull(k,:) = T * trapz(acc);
        
        adata.vhalf((k-1)*2+1,:) = T * trapz(acc(1:drows/2,:));
        adata.vhalf((k-1)*2+2,:) = T * trapz(acc(drows/2+1:end,:));
    end
    
    meanfull = mean(adata.vfull);
    adata.mvfull = zeros(rows,18);
    for x = 1:size(adata.vfull,1)
        adata.mvfull(x,:) = adata.vfull(x,:) - meanfull;
    end
    adata.varfull = var(adata.mvfull);
    
    meanhalf = mean(adata.vhalf);
    adata.mvhalf = zeros(rows*2,18);
    for x = 1:size(adata.mvhalf,1)
        adata.mvhalf(x,:) = adata.vhalf(x,:) - meanhalf;
    end
    adata.varhalf = var(adata.mvhalf);
end

