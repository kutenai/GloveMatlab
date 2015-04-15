function imudataAngles( data, nSteps )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if nSteps < 0
        nSteps = size(data,1);
    end

    gai = [];for x=0:3;gai = [gai x*7+6:x*7+8];end
    ggi = [];for x=0:3;ggi = [ggi x*7+3:x*7+5];end
    
    % Convert data to m/s^2
    acc = 2*data(:,gai)./(2^15-1);
    
    % convert angles to rad/s
    factor = (500/360)*2*pi;
    gyro = factor*data(:,ggi)./(2^15-1);
    
    for x = 0:3
        meanacc = acc(nSteps,x*3+1:x*3+3);
        phi = atan2(meanacc(2),meanacc(3));
        psi = atan2(-meanacc(1),sqrt(meanacc(2)^2+meanacc(3)^2));
        
        meangyro = gyro(nSteps,x*3+1:x*3+3);
        s = sprintf('x:%d Phi = %f Psi = %f Gyro Bias %f, %f, %f\n',x,phi*360/(2*pi),psi*360/(2*pi),meangyro(1),meangyro(2),meangyro(3));
        disp( s);
    end
end

