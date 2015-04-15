function [dms]=deg2dms(deg)
% 
% The following code converts an angle in degrees to
% an angle in degree, minute, second format
% 
% See Problem 2.3 in Chapter 2 of the book 
% Aided Navigation: GPS and high rate sensors
% Jay A. Farrell, 2008, Mc Graw-Hill
% 
% This software is distibuted without a written or implied warranty. 
% The software is for educational purposes and is not intended for
% use in applications. Adaptation for applications is at the
% risk of the user/developer.
%

lat_d=floor(deg);				                 % degrees
lat_m=floor((deg-lat_d)*60);                % minutes
lat_s=     ((deg-lat_d)*60-lat_m)*60; % seconds
dms = [lat_d,lat_m,lat_s];
