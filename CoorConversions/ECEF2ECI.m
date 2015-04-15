function eci = ECEF2ECI(ecef,varargin)

dt = 0;
eci = 0;

% resolve inputs
if nargin == 2
    if isfloat(varargin{1}) dt = varargin{1}; end
end

% prepare input to conversion function
outPtr = libpointer('doublePtr',ones(1,6));
if isstruct(ecef)
    if sum(isfield(ecef,{'x','y','z','xdot','ydot','zdot'}))==6
        in = [ecef.x ecef.y ecef.z ecef.xdot ecef.ydot ecef.zdot];
        inPtr = libpointer('doublePtr',in);
    else
        errorstr = sprintf('Unexpected input format.\nPlease provide ecef.x,y,z,xdot,ydot,zdot.');
        errordlg(errorstr);
        return;
    end
else
    if length(ecef)==6
        inPtr = libpointer('doublePtr',ecef);
    else
        errorstr = sprintf('Unexpected input format.\nPlease provide ecef.x,y,z,xdot,ydot,zdot.');
        errordlg(errorstr);
        return;
    end
end

% load library if not loaded
if(~libisloaded('CoorConversionDLL'))
    if(~LoadCoorConversionDLL)
        errordlg('Failed to load coordinate conversion library!\nConfirm proper working directory.');
        return;
    end
end

% call function
[ecefVect, eciVect] = calllib('CoorConversionDLL','ECEF2ECI',inPtr,dt,outPtr);
eci.x = eciVect(1); eci.y = eciVect(2); eci.z = eciVect(3);
eci.xdot = eciVect(4); eci.ydot = eciVect(5); eci.zdot = eciVect(6);


    