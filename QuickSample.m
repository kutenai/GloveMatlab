function [ gd ] = QuickSample( n )
%QuickSample - capture some accelerometer/gyro data and perform basics
%stats

    gd = GloveData()
    
    gd.Capture(n, 1/40);
    
end

