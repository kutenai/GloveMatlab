classdef GloveTest < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        imuObj
    end
    
    methods
        function obj = GloveTest()
        end

        function PlayData(obj,din)
            
            acc = din.acc;
            gyro = din.gyro;
            
            obj.imuObj = GloveIMU();

            nItems = size(acc,1);
            
            obj.imuObj.ResetGlove();
            obj.UpdateGlove();
            tStart = tic;
            for x = 1:nItems
                obj.imuObj.Update(gyro(x,:),acc(x,:),1/40);
                obj.UpdateGlove();
                pause(1/40);
            end
            tElapsed = toc(tStart);
            display(sprintf('Total time is %f Time per item is %f', tElapsed,tElapsed/nItems));
            obj.imuObj = [];
        end
        
        function UpdateGlove(obj)
            eAngles = obj.imuObj.EulerAngles();
            for x = 1:6
                rpq = eAngles(x,[3 1 2]).*[-1 0 -1];
                %GyroGloveClient(x-1,[0 0 1 -yaw roll -pitch],0);
                GyroGloveClient(x-1,[0 0 1 rpq],0);
            end
        end

        function plotAlignData(obj,n)
            % Debug function to allow me to look at some of the data used
            % for the alignment. I wanted a quick way to examine the data
            % to insure I had approprate ranges and also to get a feel for
            % if the data was what I would expect, based on knowledge of
            % how the glove was moved during that time.
            
            figure;
            for x = 1:2
                start = obj.alignRanges(x,1);
                stop = obj.alignRanges(x,2);
                accData = obj.accFactor*double(obj.theData(start:stop,obj.accIndexes));

                % Plot the hand
                subplot(2,2,x);
                plot(accData(:,1:3));
                title(['hand ' x]);
                grid;
                
                % Plot other item
                subplot(2,2,x+2);
                plot(accData(:,4+(n-1)*3:6+(n-1)*3));
                title(['FT ' x]);
                grid;
                
            end
        end
    end
    
end

