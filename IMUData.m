classdef IMUData < handle
    % IMUData Wrap the temp, gyro*3 and acc*3 data.
    % This class will take a set of data that is N
    % rows by 7 columns. Column 1 is temp, then columns
    % 2-4 are gyro x,y,z and columns 4-7 are accelerator x,y,z
    % I will put functions for calculating various things here.

    properties
        rawdata
        
        temp
        gyro
        igyro
        acc
        
    end % properties
    
    
    methods
    
        function obj = IMUData(data)
            obj.rawdata = data;
            
            obj.temp = data(:,1);
            obj.gyro = data(:,2:4);
            obj.acc = data(:,5:7);
        end
        
        % Enter the T value in milliseconds.
        function IntGyro(obj,T)
            tvals = [0:1/T:10]';
            tvals = tvals(1:size(obj.gyro(:,1),1),1);
            
            obj.igyro = [];
            for k = 1:3
                obj.igyro(:,k) = cumtrapz(obj.GyroData(k),tvals);
            end
            
            plot(tvals,obj.igyro);
            
        end
        
        function Rout = Body2Inertial(obj,Rin,psi,theta,phi)
            
            R1 = [cos(psi) sin(psi) 0;-sin(psi) cos(psi) 0;0 0 1];
            R2 = [cos(theta) 0 -sin(theta);0 1 0;sin(theta) 0 cos(theta)];
            R3 = [1 0 0;0 cos(phi) sin(phi);0 -sin(phi) cos(phi)];
            
            Rout = R3*R2*R1*Rin;
        end
        
        % Perform data conversions on the gyro data to put it into
        % degrees per second.
        function gd = GyroData(obj,idx)
            gd = 250*obj.gyro(:,idx)/2^15-1;
        end
        
        function Plot(obj)
            
            %h = subplot(3,1,1);
            %plot(obj.temp);
            %title('Temperature');
            
            h = subplot(2,1,1);
            plot(250*obj.gyro/(2^15-1));
            title(['Rotation in ' 'degrees per second']);
            ylim([-250 250]);
            
            h = subplot(2,1,2);
            plot(2*obj.acc/(2^15-1));
            title('Acceleration in G');
            ylim([-2 2]);
        end
    
    
    end % Methods
    
end % Class
