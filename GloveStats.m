function [gdata, adata] = GloveStats( varargin )
%GloveStats Calculate integration variance and std dev
% Read files from the directory specified. The direcory is assumed to
% contain files numbered *1 to *N. Each file is a 1 minute or 30 second
% capture of glove data with no or minimal motion. This funcion will
% integrate the gyro and accelerometer data at 30 second and 1 minute
% intervals, and capture all of those statistics. Then, the integration
% statistics will be calculated for all of the 30 second and 1 minute
% values.

    if nargin > 0
        fdir = varargin{1};
    else
        fdir = '../GloveChar/';
    end
    
    T = 0.01;

    files = dirc([fdir '/*.mat'],'f','n');
    
    nFiles = size(files,1);
    afullMin = zeros(60,18); % Total number of statistics
    ahalfMin = zeros(120,18);
    gfullMin = zeros(60,18); % Total number of statistics
    ghalfMin = zeros(120,18);

    g = GloveData;
    
    gdata = struct();
    adata = struct();
    
    skip = 100;
    rows = size(files,1);
    gdata.full = zeros(rows,18);
    gdata.half = zeros(rows*2,18);
    
    adata.mfull = zeros(rows,18);
    adata.vfull = zeros(rows,18);
    adata.nfull = zeros(rows,6);
    adata.mhalf = zeros(rows*2,18);
    adata.vhalf = zeros(rows*2,18);
    adata.nhalf = zeros(rows*2,6);
    
    accmean = zeros(1,18);
    
    
    
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

        acc = data(skip+1:size(data,1),g.accIndexes)*g.accFactor;
        gyro = data(skip+1:size(data,1),g.gyroIndexes)*g.gyroFactor;
        drows = size(acc,1);
        
        if k == 1
            % Store this as the mean value
            accmean = mean(acc,1);
        end
        
        for xx = 1:drows
            acc(xx,:) = acc(xx,:) - accmean;
        end
        
        normacc = zeros(drows,6);
        for x = 0:drows-1
            for y = 0:5
                normacc(x+1,y+1) = norm(acc(x+1,y*3+1:y*3+3),2);
            end
        end
        
        % Deal with the gyro data. Integrate this and then take the mean
        % and variance.
        gdata.full(k,:) = T*trapz(gyro,1);
        
        for y = 1:2
            if y == 1
                start = 1;
                stop = size(gyro,1)/2;
            else
                start = size(gyro,1)/2+1;
                stop = size(gyro,1);
            end
                
            gdata.half((k-1)*2+y,:) = T*trapz(gyro(start:stop,:),1);
        end

        adata.ifull(k,:) = T*trapz(acc)/60;
        adata.mfull(k,:) = mean(acc,1);
        adata.vfull(k,:) = var(acc,1);
        for x = 0:5
            adata.nfull(k,x+1) = norm(adata.mfull(k,x*3+1:x*3+3));
        end

        for y = 1:2
            i = (k-1)*2;
            if y == 1
                start = 1;
                stop = size(acc,1)/2;
            else
                start = size(acc,1)/2+1;
                stop = size(acc,1);
            end
            adata.mhalf(i+y,:) = mean(acc(start:stop,:),1);
            adata.vhalf(i+y,:) = var(acc(start:stop,:),1);
        end
    end
end

function [full,half] = FullHalf(d)
    half = zeros(size(d,1),size(d,2));
    half(1,:) = d(1:size(d,1)/2,:);
    half(2,:) = d(size(d,1)/2+1:size(d,1),:);
    full = sum(half,1);
end

function [mean, var] = statts(d)
end

