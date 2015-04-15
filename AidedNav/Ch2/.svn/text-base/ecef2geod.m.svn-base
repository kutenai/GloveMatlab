function [geod]=ecef2geod(p_ecef)
% The following code coverts ECEF cartesian coords to geodetic coords.
% The input p_ecef is the position in meters
% as described in Chapter 2 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% risk of the user/developer.
%
%
% output geod=lat,long,alt in deg, deg, meters

% The fdollowing positions are for Problem 2.5
p_ecef=[  -2.430601828e+006,-4.702442703e+006,3.546587358e+006];   % path base antenna
p_ecef=[   5.057590377e+006,2.694861463000000e+006,-2794229.000];     % Pretoria
p_ecef=[      -4.646678571, 2.549341033,-3.536478881]*10^6;     % Sydney
p_ecef=[       3.338602399, 1.7433413612,5.130327709]*10^6;     % Minsk
p_ecef=[      -6.130311688,-0.888649276,-1.514877991]*10^6;     % Samoa
p_ecef=[      -2430696.672,-4704191.019,3544328.438];           % UCR ant 1


% WGS84 parameters, meters
a = 6378137.0;
b = 6356752.314;
f = (a-b)/a;
e = sqrt((2-f)*f);

x=p_ecef(1);
y=p_ecef(2);
z=p_ecef(3);


R   = sqrt(x*x+y*y+z*z);
%lng_r = (atan2(y,x))
lng = 180*(atan2(y,x)/pi);
h(1)=0;
N = a;
rr = sqrt(x*x+y*y);

for i=1:20,
    sphi=z/(N*(1-e*e)+h(i));
    phi(i)=atan((z+e*e*N*sphi)/rr);
    N = a/sqrt(1-e*e*sphi*sphi);
    h(i+1)=rr/cos(phi(i)) - N;
end;

alt=h(i);

if z<0,     % just for conversion to deg:min:sec
    phi=-phi   % south
end
lat=phi(i)*(180/pi);
lat_d=floor(lat);				% degrees
lat_m=floor((lat-lat_d)*60);    % minutes
lat_s=     ((lat-lat_d)*60-lat_m)*60; % seconds
lat = [lat_d,lat_m,lat_s];

if y<0,  % just for conversion to deg:min:sec
    lng=-lng   % west
end
lng_d=floor(lng );				% degrees
lng_m=floor((lng -lng_d)*60); % minutes
lng_s=     ((lng -lng_d)*60-lng_m)*60; % seconds
lng_east = [lng_d,lng_m,lng_s];

geod=[lat;lng_east;alt,0,0];