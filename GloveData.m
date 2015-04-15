classdef GloveData < handle
    %GloveData Capture and process glove data
    %   Put any methods used to manipulate the data here. Also, delegate
    %   all of the capture operations to this class. I've been splattering
    %   those around to other areas and that does not make a lot of sense.
    
    properties
        % Store raw data as collected from the Glove Server
        rawData
        
        % Store seperated data
        accData
        gyroData
        
        % Keep a vector of the column indexes for all of the accelerometers
        % and then all of the gyros.. makes such indexing much faster
        accIndexes
        gyroIndexes
                
        % Multiplication factor for gyro and acc data.
        gyroFactor
        accFactor
        
        nHistory
        accHist
        gyroHist
        vHist
        pHist
            
    end
    
    methods
        
        function obj = GloveData(data)
            display('Constructing GloveData');
            % store these factors for later use.x`x`
            obj.gyroFactor = (250/360)*2*pi/(2^15-1);
            obj.accFactor = 2/(2^15-1);
            
            obj.accIndexes = [];
            obj.gyroIndexes = [];
            for x = 0:5
                obj.accIndexes = [obj.accIndexes 5+(x*6):7+(x*6)];
                obj.gyroIndexes = [obj.gyroIndexes 2+(x*6):4+(x*6)];
            end
            
            if nargin > 0
                [r,c] = size(data);
                if c == 37
                    % This is normal full data
                    obj.rawData = data;
                    obj.accData = data(:,obj.accIndexes);
                    obj.gyroData = data(:,obj.gyroIndexes);
                else
                    display('This data is not formatted properly');
                end
            end
        end
        
        function delete(obj)
            % The capture may be stopped, or no connection
            display('Deleting GloveData');
            try
                GyroGloveCapture({'stop'});
            catch e
            end
            GyroGloveCapture({'close'});
        end
        
        function StartCapture(obj,histsize)
            if nargin > 0
                obj.nHistory = histsize;
                obj.accHist = zeros(histsize,18);
                obj.gyroHist = zeros(histsize,18);
                obj.vHist = zeros(histsize,18);
                obj.pHist = zeros(histsize,18);
            else
                obj.nHistory = 0;
            end
            GyroGloveCapture({'connect'});
            GyroGloveCapture({'start'});
        end
        
        function [cnt,acc,gyro] = GetData(obj,n)
            % Retrieve any new data from the Glove Server. Maximum of 5
            % packets, should normally only return 1. This method could use
            % some improvement, it currently polls for new data, but I'd
            % like to improve that a bit.
            [vals,cnt] = GyroGloveCapture({'recv',5});

            if cnt
                src = [1:cnt];

                acc = obj.accFactor*double(vals(src,obj.accIndexes));
                gyro = obj.gyroFactor*double(vals(src,obj.gyroIndexes));

                if obj.nHistory > 0
                    obj.accHist = circshift(obj.accHist,[-cnt 0]);
                    obj.gyroHist = circshift(obj.gyroHist,[-cnt 0]);

                    dest = [obj.nHistory-(cnt-1):obj.nHistory];
                    obj.accHist(dest,:) = acc;
                    obj.gyroHist(dest,:) = gyro;
                end
            else
                acc = [];
                gyro = [];
            end
        end
        
        function StopCapture(obj)
            GyroGloveCapture({'stop'});
            GyroGloveCapture({'close'});
        end
        
        function d = getAccHist(obj,n,col)
            srcCol = col+n*3;
            d = obj.accHist(:,srcCol);
        end
        
        function d = getGyroHist(obj,n,col)
            srcCol = col+n*3;
            d = obj.gyroHist(:,srcCol);
        end
        
        function d = getVHist(obj,n,col)
            srcCol = col+n*3;
            d = obj.vHist(:,srcCol);
        end
        
        function d = getPHist(obj,n,col)
            srcCol = col+n*3;
            d = obj.pHist(:,srcCol);
        end
        
        function UpdateState(obj,V,P)
            % V and P are 6x3 arrays of the velocity and position of the 6
            % IMU's in the glove.
            
            obj.vHist = circshift(obj.vHist,[-1 0]);
            obj.pHist = circshift(obj.pHist,[-1 0]);
            obj.vHist(obj.nHistory,:) = reshape(V,1,18);
            obj.pHist(obj.nHistory,:) = reshape(P,1,18);
        end
        
        function Capture(obj,n, T)
            GyroGloveCapture({'connect'});
            GyroGloveCapture({'start'});

            obj.rawData = zeros(n,37);
            obj.accData = zeros(n,18);
            obj.gyroData = zeros(n,18);

            curridx = 0;
            currTime = 0;
            T = 1/40;
            while curridx < n
                [vals,count] = GyroGloveCapture({'recv',10});
                if count > 0
                    count = min(n-curridx,count);
                    dest = [curridx+1:curridx+count];
                    src = [1:count];
                    
                    obj.rawData(dest,:) = vals(src,:);
                    obj.accData(dest,:) = vals(src,obj.accIndexes);
                    obj.gyroData(dest,:) = vals(src,obj.gyroIndexes);
                    
                    curridx = curridx + count;
                    currTime = currTime + T;
                    display(sprintf('Time:%f', currTime));
                end
            end
            GyroGloveCapture({'stop'});
            GyroGloveCapture({'close'});
        end
        
        function [acc,gyro] = DataSeparate(obj,d)
            acc = double(d(:,obj.accIndexes));
            gyro = double(d(:,obj.gyroIndexes));
        end
                
    end
    
end

