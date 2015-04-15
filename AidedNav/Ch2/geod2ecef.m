%
% This function coverts geodetic coords to ECEF cartesian coordinates
% as described in Chapter 2 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% risk of the user/developer.

clear
format long

%constants
a = 6378137.0;
b = 6356752.314;
m2ft = 3.2808333;

%input data
marker.lat.deg = 13;
marker.lat.min = 49;
marker.lat.sec = 53.05;
N=0;            % 1- northern hemisphere, 0- southern hemisphere
marker.lng.deg =  171;
marker.lng.min =  45;
marker.lng.sec =  06.71;
marker.h = round(100*28/m2ft)/100 % meters
E=0;            % 1- eastern hemisphere,  0- western hemisphere

ant_ht=0;   % meters; antenna hgt above marker

% computations
if N==1,
    lat_d =   dms2deg([ marker.lat.deg,marker.lat.min,marker.lat.sec])
else
    lat_d =  -dms2deg([ marker.lat.deg,marker.lat.min,marker.lat.sec])    
end
if E==1,
    lng_d =  dms2deg([ marker.lng.deg,marker.lng.min,marker.lng.sec])
else
    lng_d = -dms2deg([ marker.lng.deg,marker.lng.min,marker.lng.sec])
end
alt   =  marker.h+ant_ht   
   
scl = 10^10;    % mm position accuracy reqs 10 decimal accuracy in radian lat and lng
lat_r = round(scl*lat_d*pi/180)/scl
lng_r = round(scl*lng_d*pi/180)/scl

f = (a-b)/a;
e = sqrt((2-f)*f);
N = a/sqrt(1-e*e*sin(lat_r)*sin(lat_r))
x = (N + alt)*cos(lat_r)*cos(lng_r);
y = (N + alt)*cos(lat_r)*sin(lng_r);
z = (N*(1-e*e)+alt)*sin(lat_r);

% round to nearest millimeter
x = round(x*1000)/1000
y = round(y*1000)/1000
z = round(z*1000)/1000

