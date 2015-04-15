classdef GyroOnlyIMU < GloveIMU
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
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
        function obj = GyroOnlyIMU()
            display('Constructing GyroOnlyIMU');
            obj = obj@GloveIMU();
        end
        
        function delete(obj)
            display('Deleting GyroOnlyIMU');
        end
        
        function Restart(obj)
            obj.currTime = 0;
            obj.State = GloveState.InitialWait;
        end
        
        function DCMUpdateAll(obj,gyro,T)
            % Take in new gyro data and accelerometer data and update the
            % DCM's with it. Doing this just for the fingers and the thumb.
            % To make this better, I need to incorporate the Kinematics of
            % the hand so that I can insure that the fingers do not get out
            % of whack... and the DCM is constrained by the kinematics of
            % the hand.
            
            % function object to calculate the skew symetric matrix
            g = reshape(gyro,3,6)';
            for x = 1:6
                %obj.DCM_B_I{x} = obj.DCMUpdateAB(obj.DCM_B_I{x},g(1,:),g(x,:),T);
                obj.DCM_B_I{x} = obj.DCMUpdate(obj.DCM_B_I{x},g(x,:),T);
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
                    obj.State = GloveState.InitialWait;
                    
                case GloveState.InitialWait
                    
                    if obj.currTime > 1.5
                        if obj.isGloveStable(40)
                            display(sprintf('Glove Stable for init at %f',obj.currTime));
                            % Align the hand with accelerometer, and then
                            % get the ROLL angle.
                            obj.DCM_B_I{1} = obj.courseAlign(mean(obj.accHistory(1:40,1:3)));
                            obj.euler1 = obj.rad2deg(obj.dcm2Euler(obj.DCM_B_I{1},[0 0 0]));
                            display(sprintf('Glove aligned at Roll angle of %f\n',obj.euler1));

                            obj.U = mean(obj.accHistory(1:40,:));
                            obj.State = GloveState.InitialZero;
                            display(sprintf('Rotate glove 90 degrees, keeping fingers stable'));
                            obj.markTime = obj.currTime;
                        end
                    end
                case GloveState.InitialZero
                    % I am waiting for the glove to NOT be stable. This
                    % keeps everything in reset state until the glove moves
                    % the fist time. While the glove remains stable, I will
                    % continue to Init the DCM's so that they are in a
                    % current state when the glove starts to move.
                    if obj.currTime - obj.markTime > 1
                        if ~obj.isGloveStable(40)
                            obj.State = GloveState.SecondZeroWait;
                            display(sprintf('Motion Detected, waiting for stable at 90 degrees. Time %f',obj.currTime));
                        end
                    end
                case GloveState.SecondZeroWait
                    if obj.isGloveStable(40)
                        obj.DCM_B_I{1} = obj.courseAlign(mean(obj.accHistory(1:40,1:3)));
                        obj.euler2 = obj.rad2deg(obj.dcm2Euler(obj.DCM_B_I{1},[0 0 0]));
                        anglediff = 90 - abs(obj.euler1(1)-obj.euler2(1));
                        if anglediff < 15
                            display(sprintf('Glove Stable for 2nd init within 5 degress of 90 at %f',obj.currTime));
                            obj.State = GloveState.SecondZero;
                            obj.V = mean(obj.accHistory(1:40,:));
                        else
                            if obj.currTime - obj.markTime > 1
                                display(sprintf('Glove aligned at Roll angle of %f\n',obj.euler2));
                                display(sprintf('Glove stable but angle diff is %f',anglediff));
                                obj.markTime = obj.currTime;
                            end
                        end
                    end
                case GloveState.SecondZero
                    display('Aligning finger and thumb DCMs to Hand.');
                    U = reshape(obj.U,3,6)';
                    V = reshape(obj.V,3,6)';
                    % Index 0 is the hand..
                    for x = 2:6
                        obj.DCM_B_I{x} = obj.AlignUV(U([1 x],:)',V([1 x],:)');
                    end
                    obj.DCM_B_I{1} = obj.courseAlign(V(1,:));
                    obj.State = GloveState.IMURun;
                    display('Entering Run State.');
                case GloveState.IMURun

                    % Update the DCM from the gyro data. In some cases,
                    % this is all we need or all that we want to use.
                    obj.DCMUpdateAll(gyro,T);
                    
                    % Course align the hand, just use the gyros to keep the
                    % fingers aligned with the hand state.
                    obj.DCM_B_I{1} = obj.courseAlign(acc(1,1:3));
                    %obj.PositionUpdate(acc,T);
                otherwise
            end
            obj.currTime = obj.currTime + T;
            %display(sprintf('Current time %f',obj.currTime));
        end
    end
    
end

