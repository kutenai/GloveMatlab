function ecef = ECI2ECEF(eci,varargin)

dt = 0;
ecef = 0;

% resolve inputs
if nargin == 2
    if isfloat(varargin{1}) dt = varargin{1}; end
end

% prepare input to conversion function
outPtr = libpointer('doublePtr',ones(1,6));
if isstruct(eci)
    if sum(isfield(eci,{'x','y','z','xdot','ydot','zdot'}))==6
        in = [eci.x eci.y eci.z eci.xdot eci.ydot eci.zdot];
        inPtr = libpointer('doublePtr',in);
    else
        errorstr = sprintf('Unexpected input format.\nPlease provide eci.x,y,z,xdot,ydot,zdot.');
        errordlg(errorstr);
        return;
    end
else
    if length(eci)==6
        inPtr = libpointer('doublePtr',eci);
    else
        errorstr = sprintf('Unexpected input format.\nPlease provide eci.x,y,z,xdot,ydot,zdot.');
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
[ecefVect, ecefVect] = calllib('CoorConversionDLL','ECI2ECEF',inPtr,dt,outPtr);
ecef.x = ecefVect(1); ecef.y = ecefVect(2); ecef.z = ecefVect(3);
ecef.xdot = ecefVect(4); ecef.ydot = ecefVect(5); ecef.zdot = ecefVect(6);