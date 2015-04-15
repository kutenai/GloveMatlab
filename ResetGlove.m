function ResetGlove()
%ResetGlove Reset the positions of the glove components
%   Reset the glove to the 0,0,0 positions

    GyroGloveClient(0,[0 0 1 0 0 0],0);
    for x = 1:5
        GyroGloveClient(x,zeros(1,6),0);
    end


end

