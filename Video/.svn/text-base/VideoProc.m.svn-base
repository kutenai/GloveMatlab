classdef VideoProc < handle
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
        
        pk          % Calculated differences between image pairs
        pksmooth
        gType = 'Roberts'
    end
    
    methods
        function obj = VideoProc(fname)
            obj.pk = [];
            obj.pksmooth = 1;
            obj.LoadVideo(fname);
        end
        
        % Load the video using mmreader.
        function LoadVideo(obj,fname)
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
                obj.mov(k).cdata = read(obj.movieObj,k);
            end
        end
        
        function writeMovie(obj,fname,frames)
            movie2avi(obj.mov,fname,'compression','None');
        end
        
        function RemoveFrames(obj,delFrames)
            for x = 1:length(delFrames)
                
            end
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
                    obj.ShowPk(axes,n,varargin{1});
                case 'Grad'
                    obj.ShowGrad(axes,n);
                case 'H&S'
                    obj.ShowHS(axes,n,varargin{2});
            end
                        
        end
        
        function pks = PkStats(obj)
            for x = 1:length(obj.pk)
                pks(x,1) = min(obj.pk(x,1).data(:));
                pks(x,2) = max(obj.pk(x,1).data(:));
            end
        end
        
        function CalcPk(obj)
            % Initialze to nFrames - 1
            pk(1:obj.nFrames-1,1) = ...
                struct('data',zeros(obj.Height,obj.Width,1,'double'));
            
            for x = 1:obj.nFrames-1
                % For each frame, calculate the different matrix.
                f1 = obj.mov(x);
                f2 = obj.mov(x+1);
                fd = obj.CalcPkDiff(f1,f2);
                pk(x).data = fd;
            end
            
            obj.pk = pk;
        end
        
        function fd = CalcPkDiff(obj,f1,f2)
            fd = double(rgb2gray(f1)) - double(rgb2gray(f2));
            fd = fd.^2;
        end
        
        function h = Gui(obj)
            h = VideoGui(obj);
        end
        
        function Show(obj,axesObj,nFrame)
            
            if nFrame > 0 && nFrame <= length(obj.mov)
                % Display into the axes handle provided.
                if obj.EnGray
                    image(rgb2gray(obj.mov(nFrame).cdata),'CDataMapping','scaled','Parent',axesObj);
                else
                    image(obj.mov(nFrame).cdata,'CDataMapping','scaled','Parent',axesObj);
                end
            end
        end
        
        function f = GetFrame(obj,nFrame)
            if nFrame > 0 && nFrame <= obj.nFrames
                f = obj.mov(nFrame).cdata;
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
        
        function ShowPk(obj,axesObj,nFrame,theta)
            
            if nFrame > 0 && nFrame < length(obj.mov)
                f1 = obj.mov(nFrame).cdata;
                f2 = obj.mov(nFrame+1).cdata;
                fd = obj.CalcPkDiff(f1,f2);
                if obj.pksmooth
                    % It's not zero..
                    fd = imfilter(fd,obj.pksmooth);
                end
                fdt = (fd > theta);

                % Display into the axes handle provided.
                % Histogram equalize it first..
                image(fdt,'CDataMapping','scaled','Parent',axesObj);
            end
        end
        
        function [gradx,grady] = CalcGrad(obj,f1)
            
            switch obj.gType
                case 'Sobel'
                    gy = [-1 -2 -1;0 0 0;1 2 1];
                    gx = [1 0 -1;2 0 -2;1 0 -1];
                case 'Roberts'
                    gy = [1 0;0 -1];
                    gx = [0 1;-1 0];
            end
            
            %grady = imfilter(rgb2gray(f1),gy);
            %gradx = imfilter(rgb2gray(f1),gx);
            I = rgb2gray(f1);
            
            dfactor = 15;
            [X,Y] = meshgrid(1:dfactor:size(I,2),1:dfactor:size(I,1));
            fsmall = interp2(double(I),X,Y);
            %figure;imshow(uint8(fsmall));
            
            
            [gradx,grady] = gradient(fsmall);
        end
        
        function ShowGrad(obj,axesObj,nFrame)
            
            if nFrame > 0 && nFrame <= length(obj.mov)
                f1 = obj.mov(nFrame);
                [gradx,grady] = obj.CalcGrad(f1.cdata);

                %contour(axesObj,gradx,grady);
                %hold on;
                %quiver(axesObj,fliplr(gradx),flipud(grady));
                quiver(axesObj,flipud(gradx),flipud(grady));
                %hold off;
            end
        end
        
        function [u,v] = CalcHS(obj,f1,f2,lambda)
            
            I1 = rgb2gray(f1);
            I2 = rgb2gray(f2);
            
            % Decimate using interp2.. makes the image a bit smaller.
            % more maneageble.
            dfactor = 15;
            [X,Y] = meshgrid(1:dfactor:size(I1,2),1:dfactor:size(I1,1));
            I1s = interp2(double(I1),X,Y);
            I2s = interp2(double(I2),X,Y);
            
            [rows,cols] = size(I1s);
            
            % Initilize uv to zero
            u = zeros(rows,cols);
            v = zeros(rows,cols);
            keepGoing = 1;
            
            switch obj.gType
                case 'Sobel'
                    gy = [-1 -2 -1;0 0 0;1 2 1];
                    gx = [1 0 -1;2 0 -2;1 0 -1];
                case 'Roberts'
                    gy = [1 0;0 -1];
                    gx = [0 1;-1 0];
            end
            
            fx = imfilter(I1s,gx);
            fy = imfilter(I2s,gy);
            fx2 = fx.^2;
            fy2 = fy.^2;
            ft = (I1s-I2s);
            
            
            h = ones(3,3)/9; % Avergaing filter.
            k = 1;
            while(keepGoing)
                ubar = imfilter(u,h);
                vbar = imfilter(v,h);
                t1 = (fx.*ubar+fy.*vbar+ft);
                t2 = (lambda^2+fx2+fy2);
                %t = (fx.*ubar+fy.*vbar+ft)./(lambda^2+fx2+fy2);
                t = t1./t2;
                uk = ubar - fx.*t;
                vk = vbar - fy.*t;
                
                if k > 20
                    keepGoing = 0;
                end
                
                eu = abs(max(max(uk-u)));
                ev = abs(max(max(vk-v)));
                if eu < 0.1 && ev < 0.1
                    keepGoing = 0;
                end
                u = uk;
                v = vk;
                k = k + 1;
            end
            
        end
        
        function ShowHS(obj,axesObj,nFrame,lambda)
            
            if nFrame > 0 && nFrame < (obj.nFrames-1)
                f1 = obj.mov(nFrame);
                f2 = obj.mov(nFrame+1);
                [u,v] = obj.CalcHS(f1.cdata,f2.cdata,lambda);

                %contour(axesObj,gradx,grady);
                %hold on;
                quiver(axesObj,flipud(u),flipud(v));
                %hold off;
            end
        end
        
        function d = PosData(obj)
            d = [];
        end
        
        % Play as a movie
        function Play(obj,start,nFrames,cnt)
            hf = figure;
            set(hf,'position',[150 150 obj.Width obj.Height]);
            movie(hf,obj.mov(start:min(obj.nFrames,start+nFrames)),cnt);
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

