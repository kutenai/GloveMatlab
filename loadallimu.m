function data = loadallimu(varargin)
    % Load all of the .mat files in the specified data directory. These
    % were the original files of data captured. There were some issues with
    % the data, namely it was not modified to have the x,y,z axes fixed,
    % and the biggest problem is that the order of the data is suspect. I
    % did some fixing of the capture later, so I am not certain of the
    % ordering of the IMU data. Hand is always first, then the other items
    % are unclear.

    if nargin > 0
        fdir = varargin{1};
    else
        fdir = '../DataCollection/';
    end

    files = dir([fdir '/*.mat']);
    
    data = struct();

    for k = 1:size(files,1)
        f = files(k);
        [pathstr,name,ext] = fileparts(f.name);
        disp (f.name);
        t = load([fdir f.name]);
        % Some of the newer structures include a .Name and a .T
        % value. .Name specifies the name directly, older structures
        % just had the first field be the data.. I could not specify
        % anyting else, like the period.
        if isfield(t,'Data')
            data.(name).('data') = t.Data;
        else
            fn = fieldnames(t);
            field = fn{1};
            data.(name).('data') = getfield(t,field);
        end
        
        if isfield(t,'T')
            data.(name).('T') = t.T;
        else
            % This is the default for old data that did not specify
            % otherwise
            data.(name).('T') = 1/180;
        end
    end
end
   
