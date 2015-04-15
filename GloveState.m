classdef GloveState
    %GloveState State Enumeration for GloveIMU class
    
    enumeration
        Idle               % Everything reset to zero
        InitialWait        % Wait for glove to be steady
        
        % Average data to remove gyro biases and determine initial DCMs for
        % Hand/Finger/Thumb to Inertial frame
        InitialZero
        
        % Request user move hand to second position, 90 degrees from
        % initial in order to measure the FingerThumb -> Hand DCM
        SecondZeroWait
        
        % Integrate second zero data
        SecondZero
        
        % Enter the Run state, where the DCM's will be updated with Gyro
        % data and hopefully eventually will be 
        IMURun
        
    end
    
end

