classdef IMUVideoProc < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        EnGray = true
    end
    
    properties
        movieObj
        mov
        Width
        Height
        nFrames
        currStartFrame
        
        pk          % Calculated differences between image pairs
        pksmooth
        gType = 'Roberts'
    end
    
    methods
        function obj = IMUVideoProc(fname)
            obj.pk = [];
            obj.pksmooth = 1;
            obj.LoadVideo(fname)
            
            % Better limit this to 100 frames at a time.
            mov(1:60) = ...
                struct('cdata', zeros(obj.Height, obj.Width,3,'uint8'),...
                    'colormap',[]);
                
            obj.mov = mov;
            %obj.LoadFrames(1);
                
        end
        
        % Load the video using mmreader.
        function LoadVideo(obj,fname)
            obj.movieObj = mmreader(fname);
            obj.nFrames = obj.movieObj.NumberOfFrames;
            obj.Height = obj.movieObj.Height;
            obj.Width = obj.movieObj.Width;
        end
        
        function n = FrameCount(obj)
            n = obj.nFrames;
        end
        
        function fmts = CalcFormats(obj)
            fmts = {'Pk','Grad','H&S'};
        end
        
        function ShowCalc(obj,axes,n,fmt,varargin)
            switch fmt
                case 'Pk'
                    %obj.ShowPk(axes,n,varargin{1});
                case 'Grad'
                    %obj.ShowGrad(axes,n);
                case 'H&S'
                    %obj.ShowHS(axes,n,varargin{2});
            end
                        
        end
        
        function pks = PkStats(obj)
            for x = 1:length(obj.pk)
                pks(x,1) = min(obj.pk(x,1).data(:));
                pks(x,2) = max(obj.pk(x,1).data(:));
            end
        end
        
        function h = Gui(obj)
            h = VideoGui(obj);
        end
        
        function Show(obj,axesObj,nFrame)
            
            if nFrame > 0 && nFrame <= obj.nFrames
                % Display into the axes handle provided.
                if obj.EnGray
                    image(rgb2gray(read(obj.movieObj,nFrame)),'CDataMapping','scaled','Parent',axesObj);
                else
                    image(read(obj.movieObj,nFrame),'CDataMapping','scaled','Parent',axesObj);
                end
            end
        end
        
        function f = GetFrame(obj,nFrame)
            if nFrame > 0 && nFrame <= obj.nFrames
                f = obj.mov(nFrame).cdata;
                %f = read(obj.movieObj,nFrame);
            else
                f = [];
            end
        end
        
        function SetPkSmooth(obj,smoothType)
            switch smoothType
                case 'None'
                    obj.pksmooth = 0;
                case '9x9'
                    obj.pksmooth = ones(9,9)/(9*9);
                case '3x3'
                    obj.pksmooth = ones(3,3)/9;
            end
        end
        
        function LoadFrames(obj,start)
            for k = start : min(start+60,obj.nFrames)
                obj.mov(k).cdata = read(obj.movieObj,k);
            end
            obj.currStartFrame = start;
        end
        
        % Play as a movie
        function Play(obj,start,cnt)
            hf = figure;
            set(hf,'position',[150 150 obj.Width obj.Height]);
            if start ~= obj.currStartFrame
                obj.LoadFrames(start);
            end
            movie(hf,obj.mov(1:min(obj.nFrames,start+60)),cnt);
        end
        
        % Play part of the image as a movie.
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
    end
    
end

