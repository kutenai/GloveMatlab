function [ frames ] = loadFrames( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



	h = video.MultimediaFileReader(filename,'PlayCount',1);
    
    frmCnt = 0;
    frames = [];
    while ~isDone(h)
        frm = step(h);
        frmCnt = frmCnt + 1;
    end
    
    [r,c,planes] = size(frm);
    
    frmCnt
    frames = [frmCnt,r,c,planes];
    
    reset(h);
    idx = 1;
    while ~isDone(h)
        frm = step(h);
        frames(idx,:,:,:) = frm;
        idx = idx + 1;
    end
     

end

