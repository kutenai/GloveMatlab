classdef HandKinematics < handle
    %HandKinematics Manage kinematics of hand, fingers and thumb
    %   This class managers the position kinimatics of the hand, including
    %   the fingers and the thumb. The IMU object can call this with
    %   updated values to determine if those values are valid. How exactly
    %   this gets incorporated into the IMU is unclear at the timer of this
    %   writing, but some type of Kalman or particle filter, etc. would
    %   probably be the ideal solution.
    
    properties
        eAngles
        Positions
    end
    
    methods
        function obj = HandKinematics()
        end
        
        function UpdatePanda(obj)
            obj.UpdateGlove();
        end
        
        function UpdateAngles(obj,eAngles)
            obj.eAngles = eAngles;
        end
        
        function UpdatePos(obj,newPos)
            obj.Positions = newPos;
        end
        
        function UpdateGlove(obj)
            % Update the Panda3D visualization with current hand, finger
            % and thumb positions and orientations.
            
            %eAngles = obj.imuObj.EulerAngles();
            %Pos = obj.imuObj.Positions();
            if size(obj.eAngles,1) > 0
                eAngles = obj.eAngles;
                Pos = obj.Positions;
                Pos = [0 0 1;zeros(5,3)];
                Row2Glove = [0 3 2 5 1 4];

                % Upate the hand using all 3 gyro values.
                rpq = eAngles(1,:);
                GyroGloveClient(0,[0 0 0 rpq],0);

                Finger2Idx = fliplr([5 3 2 6]);
                for x = 1:4
                    idx = Finger2Idx(x);
                    rpq = eAngles(idx,:);
                    pos = [2.5 0 0];
                    FingerAngle(x,pos',rpq(2));
                    %GyroGloveClient(Row2Glove(x),[pos 0 rpq(2) 0],0);
                end
                
                % Do the Thumb
                rpq = eAngles(4,:);
                pos = [3 1 -0.5];
                obj.ThumbAngle(pos',rpq(2));
            end
            
            % Ignore the thumb for now..
            
        end
        
        function singular = FingerAngle(obj,fidx,pos, angle)
        %FingerAngle Translate position in X and Z axis based on angle.
        %   Calculate the rotation of the finger and translation of the position
        %   value. I am limiting the range of angle from +20 to -90. Fingers can
        %   move much more than that, but I am making this simple approximation for
        %   now.

            if angle > 20 || angle < -90
                singular = true;
                return;
            end
            singular = false;

            rangle = (angle/360)*2*pi;
            C = [cos(rangle) 0 sin(rangle)
                0 1 0
                sin(rangle) 0 cos(rangle)];

            try
                newpos = C*pos;

                GyroGloveClient(fidx,[newpos' 0 angle 0],0);
            catch e
                display('Error when doing translation.');
            end
        end
        
        function singular = ThumbAngle(obj,pos,angle)
        %FingerAngle Translate position in X and Z axis based on angle.
        %   Calculate the rotation of the finger and translation of the position
        %   value. I am limiting the range of angle from +20 to -90. Fingers can
        %   move much more than that, but I am making this simple approximation for
        %   now.

            if angle > 30 || angle < -90
                singular = true;
                return;
            end
            singular = false;

            rangle = (angle/360)*2*pi;
            C = [cos(rangle) 0 sin(rangle)
                0 1 0
                sin(rangle) 0 cos(rangle)];

            try
                newpos = C*pos;

                GyroGloveClient(5,[newpos' 0 angle 0],0);
            catch e
                display('Error when doing translation.');
            end
        end

    end
    
end

