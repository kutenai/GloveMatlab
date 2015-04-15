classdef Video < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        movieObj
        mov
        Width
        Height
        nFrames
        Figure
        
    end
    
    methods
        function obj = Video(fname)
            obj.movieObj = mmreader(fname);
            obj.nFrames = obj.movieObj.NumberOfFrames;
            obj.Height = obj.movieObj.Height;
            obj.Width = obj.movieObj.Width;
            
            mov(1:obj.nFrames) = ...
                struct('cdata',zeros(obj.Height,obj.Width,3,'uint8'),...
                'colormap',[]);
            
            display(sprintf('Importing %d frames.',obj.nFrames));
            obj.mov = mov;
            for k = 1 : obj.nFrames
                %obj.mov(k).cdata = read(obj.movieObj,k);
            end
        end
        
        function Play(obj,start,nFrames,cnt)
            hf = figure;
            set(hf,'position',[150 150 obj.Width obj.Height]);
            movie(hf,obj.mov(start:min(obj.nFrames,start+nFrames)),cnt);
        end
        function PlayIt(obj,nFramesPerIt)
            hf = figure;
            tFrames = obj.nFrames;
            nIts = floor(tFrames/nFramesPerIt);
            set(hf,'position',[150 150 obj.Width obj.Height]);
            endFrame = 0;
            for x = 0:nIts
                start = endFrame + 1;
                endFrame = start + nFramesPerIt;
                display(sprintf('Playing frames %d to %d\n',start,endFrame));
                movie(hf,obj.mov(start:min(endFrame,obj.nFrames)),1);
            end
        end
        
        function PlaySparse(obj)
            hf = figure;
            for k = 1 : obj.nFrames
            	imshow(read(obj.movieObj,k));
            end
        end
    end
    
end

