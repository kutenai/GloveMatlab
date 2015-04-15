function [ output_args ] = imuplot( imudata, imuidx )
%imuplot Plot one set of IMU data from a data set.
%   Pass in a set of IMU data that contains 1 or more
% sets of IMU data. Each set will be 7 columns, temp
% and then gx, gy, gz, ax, ay, az
% The index will pick which set to plot, starting at 0
% for the first set, 1 for the second, etc.

    [r,c] = size(imudata);
    numIMUs = int8((c-1)/7);
    if imuidx >= numIMUs
        error('imuplot',sprintf('IMU index out of range: %s .',imuidx));
    end
    
    T = 0.01;
    start = 340;
    stop = 360;
    t = [0:0.01:(r-1)*0.01];
    t = [start*T:T:stop*T];
    
    myimu = imudata(:,imuidx*7+2:imuidx*7+8);
    
    myimu(:,1) = (35+(myimu(:,1)+13200)/280);
    for x=2:4
        % Gyro calculations
        myimu(:,x) = 250*(myimu(:,x)/2^15);
    end
    
    for x=5:7
        myimu(:,x) = 2*(myimu(:,x)/2^15);
    end
    
    fh = figure;
    subplot(3,1,1);

    for x=[5:7]
        subplot(3,1,x-4);
        plot(t,myimu(start:stop,x));
        ylabel('acc. G');
        grid;
        mean(myimu(start:stop,x))
    end

end

