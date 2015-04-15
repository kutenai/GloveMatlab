classdef IMUCore < handle
    % IMUCore Core functions for performing the IMU calcuations.
    %   These are the most generic functions. Classes that derive from this
    %   one can override these or add more.
    
    properties
        
        nIMUs
        
        % History for averaging purposes
        histSize
        gyroHistory
        accHistory
        
        rad2deg
        
        hKinematics
    end
    
    methods
        function obj = IMUCore(nIMUs)
            display('Constructing IMUCore');
            obj.nIMUs = nIMUs;
            obj.rad2deg = @(x) (x/(2*pi))*360;
            obj.hKinematics = [];
        end
        
        function delete(obj)
            display('Deleting IMUCore');
        end
        
        function dcm = DCMUpdate(obj,dcmin,gyro,T)
            ssomega = @(omega) [0 -omega(3) omega(2);omega(3) 0 -omega(1);-omega(2) omega(1) 0];
            gomega = ssomega(gyro);
            dDCM = dcmin*gomega; % This is rate of change of DCM
            dcm = dcmin + dDCM*T;
        end

        function dcm = DCMUpdateAB(obj,dcmin,gyroA,gyroB,T)
            ssomega = @(omega) [0 -omega(3) omega(2);omega(3) 0 -omega(1);-omega(2) omega(1) 0];
            gA = ssomega(gyroA);
            gB = ssomega(gyroB);
            dDCM = dcmin*gomega; % This is rate of change of DCM
            dcm = dcmin + dDCM*T;
        end

        function C = courseAlign(obj,accData)
            % This alrogithm taken directly from strapdown analytics by
            % Paul G. Savage. Many thanks to Mr. Savage for his kind
            % assistance.
            
            % ****** THIS MUST BE NORMALIZED ******
            % I was not normalizing this, so I added the /norm(accData),
            % which should take care of it.
            % Reference: Strapdown Analytics page 6-3, eq. 6.1.1-2
            c3 = -accData/norm(accData);
            c2 = zeros(1,3);
            
            % If the X axis is near vertical, we need to use a slightly
            % different initialization technique, otherwise we will have a
            % null in the denominator of the equations.
            if abs(c3(1)) < 0.85
                c2(2) = c3(3)/sqrt(c3(2)^2+c3(3)^2);
                c2(3) = -c3(2)/sqrt(c3(2)^2+c3(3)^2);
            else
                c2(1) = c3(2)/sqrt(c3(1)^2+c3(2)^2);
                c2(2) = -c3(1)/sqrt(c3(1)^2+c3(2)^2);
            end
              
            c1 = cross(c2,c3);
            %c1 = zeros(1,3);
            %c1(1) = c2(2)*c3(3)-c2(3)*c3(2);
            %c1(2) = c2(3)*c3(1)-c2(1)*c3(3);
            %c1(3) = c2(1)*c3(2)-c2(2)*c3(1);
            
            C = [c1;c2;c3];
        end
        
        function euler = dcm2Euler(obj,dcm,oldAngles)
            % Implementation of the dcm2Euler algorithm in the Strapdown
            % analytics book
            
            % This uses the values from the AeroBlockset. I'll disable that
            % for now.... I think I've got the other figured out.
            %[y,p,r] = dcm2angle(dcm);
            %euler = [r,-p,y];
            %return
            
            pitch = atan(-dcm(3,1)/sqrt(dcm(3,2)^2+dcm(3,3)^2));
            %pitch = -asin(dcm(3,1));
            %pitch = atan2(-dcm(3,1),sqrt(dcm(3,2)^2+dcm(3,3)^2));
            
            if abs(dcm(3,1)) < 0.98
                roll = atan2(dcm(3,2),dcm(3,3));
                yaw = atan2(dcm(2,1),dcm(1,1));
            else
                roll = oldAngles(1);
                yaw = oldAngles(3);
            end
            euler = [roll,pitch,yaw];
        end
        
        function dcm = AlignUV(obj,U,V)
            % implement the algorighm to calculate the DCM that maps thumb
            % and finger coordinates to hand coordinates. There will be 5
            % such matrices, all referenced to the hand matrix.
            % Input parameters are U a V, where U(1,:) and V(1,:) are two
            % vectors taken from both frames of reference, and U(2,:) and
            % V(2,:) are two distinct vectors.
            
            % Initialize W to have two columns
            W = zeros(3,2);
            
            % Generate W with the cross product
            for y = 1:2
                W(:,y) = cross(U(:,y),V(:,y));
            end
            
            % build the DA1 and DA2 matrices
            DA = zeros(3,3,2);
            for d = 1:2
                DA(:,:,d) = [U(:,d) V(:,d) W(:,d)];
            end
            
            % And, the computed DCM is the DA1 * DA2^-1
            dcm = DA(:,:,1)*DA(:,:,2)^-1;
        end
        
        function [v,p] = PositionUpdate(obj,vin,pin,dcmin,acc,T)
            % position update based on current velocity/position and new
            % accelerometer values. The accelerometer values are oriented
            % to inertial frame and then used to update the components of V
            % and P in the I frame. 
            [r,c] = size(a);
            if r == 1
                a = a';
            end
            aI = dcmin*a; %rotate to I coordinates
            aI = aI+[0 0 1]'; % remove gravity vector.
            v = vin+aI*T; % add acceleration * T to velocity
            p = pin + v*T^2; % update position
        end

        function bool = isGloveStable(obj,n)
            % Calculate if the glove has been stable over the last N
            % samples

            % Get the maximum gyro deviation of any gyro over the history.
            gmax = max(max(obj.gyroHistory(1:n,:)));

            % Don't bother with all of the calclations, just see if the
            % acceleration has been steady. If the glove is moving with
            % constant motion, we would consider that to be okay. One thing
            % this does not account for is noise, so the stability level
            % must be higher than the noise level.
            maxDev = max(max(obj.accHistory(1:n,:))-min(obj.accHistory(1:n,:)));
            
            if maxDev > 0.05 || gmax > 0.1
                bool = false;
            else
                bool = true;
            end
            %display(sprintf('T:%f Gmax:%f maxDev:%f', obj.currTime, gmax, maxDev));
            return
        end

        function ResetHistory(obj,nHistSize)
            obj.histSize = nHistSize;
            obj.gyroHistory = zeros(nHistSize,3*obj.nIMUs);
            obj.accHistory = zeros(nHistSize,3*obj.nIMUs);
        end
        
        function UpdateHistory(obj,gyro,acc)
            % Update the history values used for averaging, stability
            % detection and initialization. 
            % These history values have bias removed, which makes them
            % different from the history values in the GloveData class. I
            % was thinking of using the GloveData class, but this makes
            % that more difficult, and makes it more appropriate to keep
            % the history data in this class.
            
            obj.gyroHistory = circshift(obj.gyroHistory,[1 0]);
            obj.accHistory = circshift(obj.accHistory,[1 0]);
            
            obj.gyroHistory(1,:) = gyro;
            obj.accHistory(1,:) = acc;
        end 
        
        function SetHK(obj,hk)
            obj.hKinematics = hk;
        end
        
    end
    
end

