classdef GloveGui < GloveGuiBase
    % GloveGui Extend teh basic GloveGui to include live capture controls.
    % The GloveGuiBase provides the GUI setup code. This class adds more of
    % the logic to the class. A higher level class allowed me to isolate
    % the code better, and keep the files I work on smaller.
    
    % This class also allowed me to isolate the kinematics portions of the
    % logic, here I can override the IMU object with more specific
    % versions, or experimental versions. 
    
    properties

        myTimer
        period
        
        imuObj
        
        hKinematics
                
    end
    
    methods
        function obj = GloveGui(imuObj)
            % Constructor. Takes as an argument the
            % video processing object which contains the images and such.
            obj = obj@GloveGuiBase();

            obj.hKinematics = HandKinematics();

            % Allow an alternate - or customized - imuObj to be passed in
            if nargin == 1
                obj.imuObj = imuObj;
            else
                obj.imuObj = GloveIMU();
            end
            obj.imuObj.SetHK(obj.hKinematics);
        end
        
        function delete(obj)
            % Clean up anything that needs to be fixed up. Close timers,
            % close the data capture, etc.
            
            display('Deleting GloveGui.');
            
            try
                clear(obj.imuObj);
                clear(obj.gData);
            catch e
            end
        end
        
        function StartLive(obj,periodms)
            % Play through the sequence with a timer. This one is cool. I
            % setup a callback timer, see the Play_cb function, that is
            % called once each period.. This gives a "frame rate". A normal
            % period is probably 1/30, or technically, 1/29.7 or so.
            
            period = periodms / 1000;
            obj.period = period;
            obj.gData.StartCapture(500);
            
            % Create some IMU Objects to manage the IMU calculations. This
            % is a seperate class that makes it easier to keep the logic
            % all organized, and will make it much easier to document
            % later. It won't be the fastest performing, but that isnt the
            % primary concern at this point.
            
            obj.imuObj.ResetGlove();
            
            obj.myTimer = timer(...
                'TimerFcn',@(src,event)Live_cb(obj,src,event),...
                'Period',period,...
                'ExecutionMode','fixedRate');
            
            start(obj.myTimer);
        end
        
        function Live_cb(obj,src,event)
            % Callback for timer.. called after each period,.

            try
                [cnt,acc,gyro] = obj.gData.GetData();
            catch e
                display(sprintf('Exception in GetData:%s',e.identifier));
            end
            
            if cnt
                for x = 1:cnt
                    obj.IMU_Update(acc(x,:),gyro(x,:),obj.period);
                end
            end
        end
        
        function IMU_Update(obj,acc,gyro,T)
            % This function will perform the incremental IMU calulcations,
            % update kalman gain matrices, etc. It will then update the
            % glove position values and then update the glove visual
            % position
            
            %obj.imuObj.UpdateAccData(imudata(1,4:6),T);
            try
                obj.imuObj.Update(gyro,acc,T);
            catch e
                display(sprintf('Exception in imuObj.Update:%s',e.identifier));
                return;
            end
            
            try
                obj.IMUPlot(acc,gyro);
            catch e
                display(sprintf('Exception in obj.IMUPlot:%s',e.identifier));
                return;
            end
            
            try
                obj.hKinematics.UpdatePanda();
            catch e
                display(sprintf('Exception in obj.UpdatePanda:%s',e.identifier));
                return;
            end
            
            % Update display of IMU Data, as a data check
            chk = abs(sum(reshape(acc,3,6)',2)') > 0.2;
            set(obj.ui.text('Data Check').edit,'String',sprintf('%d  ',chk));
            dcm = obj.imuObj.DCMBody2Inertial(obj.posIndex);
            myFormat = @(x) sprintf('%5.3f',x);
            tdcm = arrayfun(myFormat,dcm,'UniformOutput',0);
            obj.SetTableData('DCM',reshape(tdcm,3,3));
        end
        
        function StopLive(obj)
            % Sto the timer, and delete it. Stop the capture process.
            try
                stop(obj.myTimer); 
                delete(obj.myTimer);
            catch e
                % No timer to delete I guess..
                delete(timerfind);
            end
                
            obj.gData.StopCapture();
        end
        
        function Restart(obj)
            display('Restarting IMU');
            obj.imuObj.Restart();
        end
        
        function Zero(ob)
        end

    end
    
end


