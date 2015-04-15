classdef VideoTimeFront < VideoProc
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Data for waterfall
        posData = []
        IV = 0
        mIV = 0
        PanMos = zeros(1,1,1);
        
        fStart
        fEnd
        xStart
        xEnd
        tw
    end
    
    methods
        function obj = VideoTimeFront(fname)
            obj = obj@VideoProc(fname);
            t = load('posData');
            obj.posData = t.posData;
        end
        
        function h = Gui(obj)
            h = VideoGuiTimeFronts(obj);
        end
        
        function [dr,dc] = RegisterFramePair(obj,ep,f1,f2)
            if size(f1,3) > 1
                f1 = rgb2gray(f1);
                f2 = rgb2gray(f2);
            end
            % Don't really need the entire image..
            rows = size(f1,1);
            cols = size(f1,2);
            rect1 = f1(0.2*rows:0.8*rows,0.2*cols:0.8*cols);
            rect2 = f2(0.2*rows:0.8*rows,0.2*cols:0.8*cols);
            
            %[drx,dcx] = ep.xcorr(rect1,rect2);
            [dr,dc] = ep.phasecorr(rect1,rect2);
            
            x = 1;
        end
        
        function RegisterFrames(obj)
            ep = ePhaseCorr();
            
            obj.posData = zeros(obj.nFrames-1,2);
            for x = 1:obj.nFrames-1
                f1 = obj.mov(x).cdata;
                f2 = obj.mov(x+1).cdata;
                [dr,dc] = obj.RegisterFramePair(ep,f1,f2);
                dr = dr - 1;
                dc = dc - 1;
                obj.posData(x,1:2) = [dr dc];
                display(sprintf('Registered frame %d at [%d %d]',x, dr, dc));
            end
        end
        
        function IV = Build3D(obj,decimate,imOrOne)
            
            %obj.RegisterFrames();
            if length(obj.posData) == 0
                error('Error: must calculate position registration data first');
            end
            
            [rows,cols,depth] = size(obj.mov(1).cdata);
            %decimate = 8;
            r = round(rows/decimate);
            c = round(cols/decimate);
            posVal = round(cumsum(obj.posData)/decimate);
            dt = max(posVal)-min(posVal);
            offsets = min(posVal);
            rOff = 1-offsets(1);
            cOff = 1-offsets(2);
            
            theight = r + dt(1);
            twidth = c + dt(2);
            nFrames = obj.nFrames-1;
            IV = zeros(theight,twidth,nFrames,'uint8');
            
            for x = 1:nFrames
                p = posVal(x,:);
                ro = rOff+posVal(x,1);
                co = cOff+posVal(x,2);
                
                % Can use this for several functions.. sometimes I want
                % ones to fill the space, sometimes the image, converted to
                % grayscale.
                if imOrOne
                    g = rgb2gray(obj.mov(x).cdata);
                    IV(ro:ro+r-1,co:co+c-1,x) = g;
                else
                    IV(ro:ro+r-1,co:co+c-1,x) = ones(r,c,'uint8');
                end
            end
        end
        
        function IV = BuildIso(obj,decimate)
            IV = obj.Bild3D(decimate,false);
            
            p = patch(isosurface(IV,.5));
            isonormals(IV,p);
            set(p,'FaceColor',[1 0 0],'EdgeColor','none');
            daspect([1 1 1]);
            view(3)
            axis tight
            camlight
            lighting gouraud
            title('Visualization of time-space surface')
            xlabel('x')
            ylabel('y')
            zlabel('z')
        
        end
        
        function BuildTimeFronts(obj)
            % Build the time fronts from the registered data.
            % This will require some inputs, but I don't know what they are
            % yet. The resulting images must start at some points after T0,
            % and end at some point before TN, or at least we need to
            % stitch together the times from T(0:k) to generate image T0,
            % and then T(1:k1) for T1, etc. This assumes a "linear" time
            % warp of course..
            
            obj.IV = obj.Build3D(1,true);
            obj.CalcFrameLocs();
        end
        
        function CalcFrameLocs(obj)
            % This will calculate a matrix that shows if a column is null
            % or not.. the result is 1 x Cols x Frames
            % so I can check if a column,time value represents a null
            % colummn or not, without checking all rows... 
            totalCols = size(obj.IV,2);
            totalFrames = size(obj.IV,3);
            obj.mIV = reshape((sum(obj.IV(:,:,:)) > 0),totalCols,totalFrames);
            
            % This baby rocks..
            % result is a cell array of two values.
            % first one is a list of all of the starting columns, which
            % represent time where X location begins..
            % next is time when X location ends.
            A = cellfun(@(s)arrayfun(@(col)find(obj.mIV(:,col),1,s),1:totalFrames),...
                {'first','last'},'UniformOutput',false);
            obj.fStart = reshape(A{1},totalFrames,1);
            obj.fEnd = reshape(A{2},totalFrames,1);
            
            % Now, do the same thing for the times..
            % Determine the start and end time for a particular "x"
            % location.
            B = cellfun(@(s)arrayfun(@(row)find(obj.mIV(row,:),1,s),1:totalCols),...
                {'first','last'},'UniformOutput',false);
            obj.xStart = reshape(B{1},totalCols,1);
            obj.xEnd = reshape(B{2},totalCols,1);
        end
        
        function tVals = GetTimeRange(obj,xVal)
            % Need to determine a start and end time for this position. In
            % order words, at what 't' value does this position start to
            % have values, and at what T value does it cease to have
            % values. There are 3 different options.
            % A) xVal is > of first frame, so t range is
            
            tVals = [obj.xStart(xVal) obj.xEnd(xVal)];
        end
        
        function BuildMosaic(obj,tMin)
            
            decimate = 1; % This is here if I need it.. but more calculations would be required....

            if obj.IV == 0
                error('Must build the Time Fronts first..');
            end
            
            % This shold already be done though..
            obj.CalcFrameLocs();
            
            tw.tMin = tMin;
            
            % Determine the start/stop cells 
            width = obj.xEnd - obj.xStart;
            uExtents = cellfun(@(s)find(width > tMin,1,s),{'first','last'});
            tw.uStart = uExtents(1);
            tw.uEnd = uExtents(2);
            tw.uRange = tw.uEnd - tw.uStart + 1;
            
            % Now, we need some time data..we need the time range for
            % xStart and the time range for xEnd.
            tw.tStartRng = obj.GetTimeRange(tw.uStart);
            tw.tEndRng = obj.GetTimeRange(tw.uEnd);
            tw.tStart = tw.tStartRng(1);
            tw.tEnd = tw.tEndRng(1);
            
            % Hmm.. let me calculate dt/dx
            dT = tw.tEnd - tw.tStart;
            dX = tw.uEnd - tw.uStart;
            tw.mVal = dT/dX;
            tw.bVal = mean([tw.tStart - tw.mVal*tw.uStart tw.tEnd - tw.mVal * tw.uEnd]);
            
            tw.nFrames = tw.tMin;
            
            [iRows,iCols,ivFrames] = size(obj.IV);
            tw.outRows = iRows;
            tw.outCols = tw.uRange;
            assert(tw.nFrames < ivFrames);
            obj.PanMos = zeros(tw.outRows,tw.outCols,tw.nFrames,'uint8');
            
            for x = 1:tw.nFrames
                % This function will apply the time warping using data
                % in the IV array and the index, i.e. time value.
                % I pass tw which is a structure with lots of good stuff in
                % it.
                imdata = obj.ApplyTimeWarp(tw, x);
                obj.PanMos(1:tw.outRows,1:tw.outCols,x) = imdata;
            end
            obj.tw = tw;
        end
        
        function g = ApplyTimeWarp(obj,tw, tVal)
            % For each value passed in, we need to build a frame that
            % contains data warped from the time front thingy.
            % Wish I could actually describe this!
            
            % Here is my frame..
            g = zeros(tw.outRows,tw.outCols,'uint8');
            
            % I'm gonna keep this simple.. T warps in column direction only.
            for c = 1:tw.outCols
                % Calculate the time value for this column..
                colTime = tw.mVal*(c+tw.uStart)+tw.bVal;
                colTime = colTime + tVal;
                colTime = round(colTime);
                
                inRow = obj.IV(:,tw.uStart+c,colTime);
                g(:,c) = inRow;
                
            end
        end
        
        function writeMovie(obj,fname)
            nFrames = size(obj.PanMos,3);
            mov(1:nFrames) = struct('cdata',[],...
                'colormap',[]);
            
            for k = 1:nFrames
                irgb = cat(3,obj.PanMos(:,:,k),obj.PanMos(:,:,k),obj.PanMos(:,:,k));
                mov(k).cdata = irgb;
            end
            
            movie2avi(mov,fname,'compression','None');
            
        end
        
        function fmts = CalcFormats(obj)
            fmts = {'TimeFront','Mosaic'};
        end
        
        function ShowCalc(obj,axes,n,fmt,varargin)
            switch fmt
                case 'TimeFront'
                    if size(obj.IV,3) > 0 && n <= size(obj.IV,3)
                        image(obj.IV(:,:,n),'CDataMapping','scaled','Parent',axes);
                    end
                case 'Mosaic'
                    if size(obj.PanMos,3) > 0 && n <= size(obj.PanMos,3)
                        image(obj.PanMos(:,:,n),'CDataMapping','scaled','Parent',axes);
                    end
            end
        end
        
        function p = PosData(obj)
            p = obj.posData;
        end
        
    end
    
end

