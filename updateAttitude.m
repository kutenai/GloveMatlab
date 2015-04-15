function ignore = updateAttitude( attitude )
    %updateAttitude Update the Panda3D server with an attitude
    %   Send the commands to the Glove server to update the
    %   displayed attitude.
    
    pitch = attitude(1:2);
    roll = attitude(3:4);
    %display(['pitch ' sprintf('%f',pitch(1)) ' roll ' sprintf('%f',roll(1))]);
    
    ignore = 0;

    GyroGloveClient(0,[0 0 2 0 roll(1) -1*pitch(1)],0);

end

