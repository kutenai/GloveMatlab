classdef GloveIMU < IMUCore
    %GloveIMU IMU Functions more specific to the GyroGlove.
    % These functions override or extend the lower level functions to
    % provide more Glove specific capabilities.
    
    properties
        
        % Save values of bias that are calculated during the init
        gyroBias
        accBias
        
        DCM_I_P = {}
        DCM_B_P = {}
        Velocity = {}
        Position = {}
        eAngles = {}
        
        currTime
        
        State  = GloveState.Idle;
        
        bGyroOnly = false
        bDCM_AccUpdate = true
        
    end
    
    methods
        
        function obj = GloveIMU()
            % Constructor for GloveIMU
            % The construture initialize all of the required data
            % structures
            
            % Initialize the IMUCore class.
            display('Constructing GloveIMU');
            obj = obj@IMUCore(6);
            
            obj.ResetGlove();
            
        end
        
        function delete(obj)
            display('Deleting GloveIMU');
        end
        
        function dcm = DCMBody2Inertial(obj,i)
            dcm = obj.DCM_I_P{i}*(obj.DCM_B_P{i})';
        end
        
        function dcm = DCMDig2Hand(obj,i,dcm_i_h)
            % DCM From a digit to the hand
            if nargin == 2
                dcm_i_h = obj.DCMBody2Inertial(1);
            end
            dcm_i_b = obj.DCMBody2Inertial(i);
            dcm = dcm_i_h' * dcm_i_b;
        end
        
        function eAngles = EulerAngles(obj,idx)
            % Caclculate and return a matrix of Euler angles, one row per
            % IMU and the columns are roll, pitch, yaw
            
            % I pass in the previous calculated values so that if we are
            % pitched up or down at about 90 degrees, we can use the
            % previous roll and yaw values.

            rad2deg = @(x) 360*(x/(2*pi));

            if nargin == 1
                eAngles = zeros(6,3);
                % Update the hand first
                DCM = obj.DCM_B_I{1};
                obj.eAngles{1} = obj.dcm2Euler(DCM,obj.eAngles{1});
                eAngles(1,:) = rad2deg(obj.eAngles{1});
                
                % Then update the fingers.
                for x = 2:6
                    % Convert DCM H to Inertial to DCM 
                    DCM = (obj.DCM_B_I{1})'*obj.DCM_B_I{x};
                    %obj.eAngles{x} = obj.dcm2Euler(obj.DCM_B_I{x},obj.eAngles{x});
                    obj.eAngles{x} = obj.dcm2Euler(DCM,obj.eAngles{x});
                    eAngles(x,:) = rad2deg(obj.eAngles{x});
                end
            else
                obj.eAngles{idx} = obj.dcm2Euler(obj.DCM_B_I{idx},obj.eAngles{idx});
                eAngles = rad2deg(obj.eAngles{idx});
            end
        end
        
        function Pos = Positions(obj)
            % Convert the cell array into a matrix and then reshape it into
            % one row per IMU with columns x,y,z
            
            Pos = reshape(cell2mat(obj.Position),3,6)';
        end
        
        function V = Velocities(obj)
            % Convert the cell array into a matrix and then reshape it into
            % one row per IMU with columns x,y,z

            V = reshape(cell2mat(obj.Velocity),3,6)';
        end
        
        function DCMZeroP_B(obj)
            
        end
        
        function DCMUpdateAll(obj,gyro,T)
            % Take in new gyro data and accelerometer data and update the
            % DCM's with it.
            
            % function object to calculate the skew symetric matrix
            g = reshape(gyro,3,6)';
            for x = 1:6
                obj.DCM_I_P{x} = obj.DCMUpdate(obj.DCM_I_P{x},g(x,:),T);
            end
            obj.hKinematics.UpdateAngles(obj.EulerAngles());
        end
        
        function DCMUpdateFromAcc(obj,acc,idx)
            % Use the accelerometer to perform a course align of the DCM.
            % This technique works well if the IMU is stationarry and the
            % gravity vector is the only real acceleration in the system.
            
            acc = reshape(acc,3,6)';
            if nargin < 3
                for x = 1:6
                    obj.DCM_I_P{x} = obj.courseAlign(acc(x,:));
                end
            else
                obj.DCM_I_P{idx} = obj.courseAlign(acc(idx,:));
            end
            obj.hKinematics.UpdateAngles(obj.EulerAngles());
        end
        
        function InitializeDCMs(obj)
            % Use the current accelerometer and gyro history values in
            % order to initialize the DCM's using the course align
            % procedure. Use the current mean gyro value as the gyro bias
            % value. This neglects all other effects, such as Earth rate.

            % Zero out the gyro bias
            gyromean = mean(obj.gyroHistory,1);
            obj.gyroBias = gyromean;

            % Goal: take the accmean data and update each of the DCM's
            % based on the gravity vector.
            accmean = mean(obj.accHistory,1);
            at = reshape(accmean,3,6)';
            for x = 1:6
                C = obj.courseAlign(at(x,:));
            end
        end
        
        function PositionUpdate(obj,acc,T)
            % This is a very rudimentary implementation of the velocity and
            % position update based on current velocity/position and new
            % accelerometer values. The accelerometer values are oriented
            % to inertial frame and then used to update the components of V
            % and P in the I frame. 
            a = reshape(acc,3,6)';
            for x = 1:6
                dcm = obj.DCM_B_I{x};
                aI = dcm*a(x,:)'; %rotate to I coordinates
                aI = aI+[0 0 1]'; % remove gravity vector.
                v = obj.Velocity{x}+aI*T; % add acceleration * T to velocity
                p = obj.Position{x} + v*T^2; % update position
                
                % Update current values.
                obj.Velocity{x} = v;
                obj.Position{x} = p;
            end
            obj.hKinematics.UpdatePos(obj.Positions);
        end
        
        function ResetGlove(obj,histSize)
            % Reset all of the internal parameters used for tracking the
            % glove position. 
            
            % The default history size is 40, generally 1 second in my
            % examples, but this is programmable.
            if nargin == 1
                histSize = 40;
            end
            
            obj.ResetHistory(histSize);
            
            obj.State = GloveState.InitialWait;
            obj.accBias = zeros(1,18);
            obj.gyroBias = zeros(1,18);
            obj.currTime = 0;
            for x=1:6
                obj.DCM_I_P{x} = eye(3);
                obj.DCM_B_P{x} = eye(3);
                obj.Velocity{x} = [0 0 0]';
                obj.Position{x} = [0 0 0]';
                obj.eAngles{x} = [0 0 0]';
            end
        end
        
        function Restart(obj)
            obj.currTime = 0;
            obj.State = GloveState.InitialWait;
        end
        
        function Update(obj,gyro,acc,T)
            % Update the set of IMU's with new gyro and accelerometer data.
            % The new data will be used to update the set of DCMs, as well
            % as the velocity and position values for each of the IMUs in
            % the system.
            
            % Note: The input format for the gyro and acc is one row per
            % IMU, and the 3 columns are the x,y, and z values.
            
            % Scale the accelerometer and gyro data. Subtract out any bias
            % values we have determined. For now the ACC Bias will be zero
            % for all settings.
            acc = acc-obj.accBias;
            
            gyro = gyro-obj.gyroBias;
            
            % I want to update the history in all state except the Idle
            % state. It makes it easier to make a seperate switch for this
            % operation rather than adding the UpdateHistory to all other
            % states of the main switch
            if ~(obj.State == GloveState.Idle)
                obj.UpdateHistory(gyro,acc);
            end
            
            switch obj.State
                case GloveState.Idle
                    obj.ResetGlove();
                    obj.State = GloveState.InitialWait;
                    
                case GloveState.InitialWait
                    
                    if obj.currTime > 1.5
                        if obj.isGloveStable(40)
                            display(sprintf('Glove Stable for init at %f',obj.currTime));
                            obj.InitializeDCMs();
                            obj.State = GloveState.InitialZero;
                        end
                    end
                case GloveState.InitialZero
                    % I am waiting for the glove to NOT be stable. This
                    % keeps everything in reset state until the glove moves
                    % the fist time. While the glove remains stable, I will
                    % continue to Init the DCM's so that they are in a
                    % current state when the glove starts to move.
                    if ~obj.isGloveStable(40)
                        obj.State = GloveState.IMURun;
                        display(sprintf('Going to Run state at %f',obj.currTime));
                    else
                        obj.InitializeDCMs();
                    end
                case GloveState.SecondZeroWait
                case GloveState.SecondZero
                case GloveState.IMURun

                    % Update the DCM from the gyro data. In some cases,
                    % this is all we need or all that we want to use.
                    %obj.DCMUpdateAll(gyro,T);
                    
                    
                    if obj.bDCM_AccUpdate
                        obj.DCMUpdateFromAcc(acc);
                    end
                    
                    %obj.DCMUpdateFromAcc(acc);
                    %obj.PositionUpdate(acc,T);
                otherwise
            end
            obj.currTime = obj.currTime + T;
            %display(sprintf('Current time %f',obj.currTime));
        end
        
    end
    
end

