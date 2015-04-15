function singular = FingerAngle( fidx,pos, angle)
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
    
    newpos = C*pos;
    
    GyroGloveClient(fidx,[newpos' 0 angle 0],0);
end

