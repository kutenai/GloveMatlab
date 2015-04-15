function enu = ECEF2ENU(ecef,varargin)

lat = 0;
lon = 0;
enu = 0;

% resolve inputs
if nargin == 3
    if isfloat(varargin{1}) lat = varargin{1}; end
    if isfloat(varargin{2}) lon = varargin{2}; end
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
[ecefVect, enuVect] = calllib('CoorConversionDLL','ECEF2ENU',inPtr,dt,outPtr);
enu.x = enuVect(1); enu.y = enuVect(2); enu.z = enuVect(3);
enu.xdot = enuVect(4); enu.ydot = enuVect(5); enu.zdot = enuVect(6);