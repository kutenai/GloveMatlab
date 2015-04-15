classdef GyroGloveAPI < handle
    %GloveAPI Connect to glove and read samples into matlab.
    % Open a serial connection, then issue the commands to the glove
    % to start a capture. 
    % Call the Read() method to capture N samples.
    
    properties
        sPort
        currTemp
        setTemp
        
        tempVals = []
        tempTimes = []
        startTime
        plotHandle
        enableLogProp = 0
        queue = []
    end
    
    methods
        function obj = GyroGloveAPI()
            % Initialize the object and open the
            % serial port.. this is pretty specific to my system!
            obj.sPort = serial('/dev/tty.usbserial-A400gKXt','BaudRate',115200);
            % obj.sPort = serial('/dev/tty.usbserial-A400gKXt','BaudRate',489795);
            set(obj.sPort,'Timeout',1);
            set(obj.sPort,'StopBits',1);
            fopen(obj.sPort);
            display('Opened the serial port');
            c = clock;
            obj.startTime = obj.getSeconds();
            obj.clearData();
        end
        
        function delete(obj)
            % Delete this object and close the serial port
            fclose(obj.sPort)
            display('Closed the serial port');
        end
        
        % More serial stuff.. 
        function initHardware(obj)
            set(obj.sPort,'Timeout',3);
            obj.setPacket('gettime\n');
            set(obj.sPort,'Timeout',1);
        end
        
        function out = sendPacket(obj,packet)
            fprintf(obj.sPort,packet);
            
            out = fscanf(obj.sPort);
            
        end
        
        function p = getOnePacket(obj)
            x = obj.sendPacket('debug 0');
            x = obj.sendPacket('stream 1');
            p = obj.getIMUPacket();
        end
        
        function p = getIMUPacket(obj)
            
            p = GyroGloveIMUPacket();
            
            while p.validPacket() == false
                p.getChars(obj.sPort);
            end
        end
        
        function p = getIMUPackets(obj,nPackets,rate)
            x = obj.sendPacket(sprintf('debug %d',rate));
            x = obj.sendPacket(sprintf('streamstart 1'));
            
            p = [];
            t = obj.getIMUPacket();
            obj.sendPacket('wd');
            p = t.data';
            for x = 2:nPackets
                t = obj.getIMUPacket();
                obj.sendPacket('wd');
                p = [p;t.data'];
            end
        end
        
        function showGX(obj)
            x = obj.sendPacket('debug 0');
            x = obj.sendPacket('rate 1clear0');
            
            gx = zeros(100,1);
            gy = zeros(100,1);
            gz = zeros(100,1);
            subplot(3,1,1);
            ylims = [-32000 32000];
            hx = plot(gx);
            set(gca,'YLimMode','manual');
            set(gca,'YLim',ylims);
            subplot(3,1,2);
            hy = plot(gy);
            set(gca,'YLimMode','manual');
            set(gca,'YLim',ylims);
            subplot(3,1,3);
            hz = plot(gz);
            set(gca,'YLimMode','manual');
            set(gca,'YLim',ylims);
            while true
                
                obj.sendPacket('stream 100');
                for x=1:100
                    t = obj.getIMUPacket();
                    r = t.data(4:6);
                    gx = [gx(2:100);r(1)];
                    gy = [gy(2:100);r(2)];
                    gz = [gz(2:100);r(3)];
                    set(hx,'YData',gx);
                    set(hy,'YData',gy);
                    set(hz,'YData',gz);
                    drawnow
                end
            end
        end
        
        % This stuff is left over from the class I copied.. for reference.
        
        function t = getSeconds(obj)
            c = clock;
            t = c(4)*3600+c(5)*60+c(6);
        end
        
        function dt = deltaTime(obj)
            dt = obj.getSeconds()-obj.startTime;
        end
        
        function enableLog(obj,en)
            obj.enableLogProp = en;
        end
        
        function saveData(obj)
            tempTimes = obj.tempTimes';
            tempVals = obj.tempVals';
            save('tempTimes.mat','tempTimes');
            save('tempVals.mat','tempVals');
            t = [tempTimes tempVals];
            save('tempData.mat','t');
        end
        
        function sendCmd(obj,cmd,val)
            % Send a command to the Arduino
            % Actually, push it into the queue and lets the
            % timer execute it... avoids issues.
            str = sprintf('%s %d\n',cmd,val);
            obj.queue = vertcat(obj.queue,{str});
            display('Pushed a command');
        end
        
        function temp = readTemp(obj)
            % Read the temperature from the Arduino
            fprintf(obj.sPort,'T\n');
            s = fgetl(obj.sPort);
            [temp,cnt] = sscanf(s,'Temp %f',1);
        end
        
        function addTemp(obj,t)
            % Insert a new temperature value.
            newTime = obj.deltaTime();
            obj.tempVals = [obj.tempVals t];
            obj.tempTimes = [obj.tempTimes newTime];
            refreshdata(obj.plotHandle,'caller');
        end
        
        function temp = TimerCall(obj)
            % Send any commands in the queue
            while size(obj.queue,2) > 0
                cmd = obj.queue{end};
                obj.queue(end) = [];
                fprintf(obj.sPort,cmd);
            end
            
            temp = obj.readTemp();
            if obj.enableLogProp == 1
                obj.addTemp(temp);
            end
        end
        
        function clearData(obj)
            % Clear out the current time and temperature log
            % results, and reset the incremental timer to 0
            obj.tempVals = [];
            obj.tempTimes = [];
            obj.startTime = obj.getSeconds();
        end
        
        function setupAxes(obj,h)
            % Plot the temperature versus time values.
            handles = guidata(h);
            ax = handles.axes1;
            axes(ax);
            obj.tempTimes = [0];
            obj.tempVals = [0];
            obj.plotHandle = plot(ax,obj.tempTimes,obj.tempVals);
            set(obj.plotHandle,'XDataSource','obj.tempTimes',...
                'YDataSource','obj.tempVals');
            set(ax,'FontSize',14);
            axes(ax);
            % cla;

            if max(obj.tempVals) < 10
                 xlim(ax,[0 10]);
            else
                 xlim(ax,'auto');
            end
            
            %ylim(axesin,[20 240]);
            set(ax,'YLim',[10 240]);
            set(ax,'XMinorGrid','on');
            set(ax,'YMinorGrid','on');
            %set(ax,'XMinorTick',5);
            %set(ax,'YMinorTick',5);
            
            xlabel(ax,'Time');
            ylabel(ax,'Temp C');
            xlim(ax,'auto');
            %display('Plot Updated');
        end
        
           
    end
    
end

