classdef PlatformIMU < GloveIMU
    % PlatformIMU Add even more specifics, such as the Kinematics.
    % 
    
    properties
        % Values for initialization
        U
        V
        
        % Euler agles for first and second alignment
        euler1
        euler2
        
        markTime
    end
    
    methods
        function obj = PlatformIMU()
            display('Constructing PlatformIMU');
            obj = obj@GloveIMU();
        end
        
        function delete(obj)
            display('Deleting PlatformIMU');
        end
        
        function Restart(obj)
            obj.currTime = 0;
            obj.State = GloveState.InitialWait;
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
                DCM_I_H = obj.DCMBody2Inertial(1);
                obj.eAngles{1} = obj.dcm2Euler(DCM_I_H,obj.eAngles{1});
                eAngles(1,:) = rad2deg(obj.eAngles{1});
                
                % Then update the fingers.
                for x = 2:6
                    % Convert DCM H to Inertial to DCM
                    DCM_H_D = obj.DCMDig2Hand(x,DCM_I_H);
                    obj.eAngles{x} = obj.dcm2Euler(DCM_H_D,obj.eAngles{x});
                    eAngles(x,:) = rad2deg(obj.eAngles{x});
                end
            else
                if idx == 1
                    DCM_I_H = obj.DCMBody2Inertial(1);
                    obj.eAngles{1} = obj.dcm2Euler(DCM_I_H,obj.eAngles{1});
                    eAngles = rad2deg(obj.eAngles{1});
                else
                    DCM_H_D = obj.DCMDig2Hand(x);
                    obj.eAngles{idx} = obj.dcm2Euler(DCM_H_D,obj.eAngles{idx});
                    eAngles = rad2deg(obj.eAngles{idx});
                end
            end
        end
        
        function PlatformInit(obj)
            % The glove has been placed flat on the table with the fingers
            % and hand down on the table as much as practical. The
            % body-inertial DCM's shold be considered vertical, so any
            % offsets are in the platform to body. Take these measurements,
            % and then initialize the Body-Inertial to Z up, 
            
            % Fingers
            acc = reshape(mean(obj.accHistory(1:40,:)),3,6)';
            for x = 1:6
                tacc = acc(x,:);
                dcm_i_p = obj.courseAlign(tacc);
                dcm_i_b = obj.courseAlign([0 0 -1]);
                obj.DCM_I_P{x} = dcm_i_p;
                obj.DCM_B_P{x} = dcm_i_p;
            end
        end
        
        function DCMUpdateAll(obj,gyro,acc,T)
            % Take in new gyro data and accelerometer data and update the
            % DCM's with it. Doing this just for the fingers and the thumb.
            % To make this better, I need to incorporate the Kinematics of
            % the hand so that I can insure that the fingers do not get out
            % of whack... and the DCM is constrained by the kinematics of
            % the hand.
            
            % function object to calculate the skew symetric matrix
            g = reshape(gyro,3,6)';
            a = reshape(acc,3,6)';
            for x = 1:6
                %obj.DCM_I_P{x} = obj.DCMUpdate(obj.DCM_I_P{x},g(x,:),T);
                obj.DCM_I_P{x} = obj.courseAlign(a(x,:));
            end
            obj.hKinematics.UpdateAngles(obj.EulerAngles());
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
                    display('Place glove flat on the table.');
                    obj.State = GloveState.InitialWait;
                    
                case GloveState.InitialWait
                    
                    if obj.currTime > 3.0
                        if obj.isGloveStable(40)
                            display(sprintf('Glove Stable for init at %f',obj.currTime));
                            obj.PlatformInit();
                            obj.State = GloveState.IMURun;
                        end
                    end
                case GloveState.InitialZero
                case GloveState.SecondZeroWait
                case GloveState.SecondZero
                case GloveState.IMURun

                    % Update the DCM from the gyro data. In some cases,
                    % this is all we need or all that we want to use.
                    obj.DCMUpdateAll(gyro,acc,T);
                    
                    %obj.PositionUpdate(acc,T);
                otherwise
            end
            obj.currTime = obj.currTime + T;
            %display(sprintf('Current time %f',obj.currTime));
        end
    end
    
end

