classdef CGrid < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        images
        imPath
        gridCells = [8 8]
        gridSize = [190 196]
        gridLineWidth = 1
        tf
        debugShow = false
    end
    
    methods
        function obj=CGrid(imPath)
            % Pass in the path of the directory that contains the
            % images. Images are assumed to have a -N index.
            
            obj.imPath = imPath;
            obj.images = {};
            obj.loadFiles(imPath);
            obj.tf = eTransform('nonlinear');
            obj.makeGridSquare();
        end
        
        function showall(obj)
            n = size(obj.imageList,1);
            for x=1:size(obj.imageList,1)
                figure(x);
                im2 = obj.imageList{x,1};
                imshow(im2);
            end
        end
        
        function pts = getInputPts(obj)
            close all;
            imshow(obj.gridInIm);
            pts = ginput();
            
        end
        
        function imout = warpImage(obj,im,dest)
            % Take any image and warp it to the destination.
            
            if strcmp(dest,'in')
                s = obj.images.in;
            else
                s = obj.images.out;
            end
            
            % Need to scale these points up to the size of the new image.
            % Resize the input image to match the aspect ratio of the 
            % grid image, and then scale the points on this grid image to
            % the new image.

            imrows = size(im,1);
            imcols = size(im,2);
            inrows = size(s.img,1);
            incols = size(s.img,2);
            
            % Determine the edge to crop the input image along
            scale = min(floor(imrows/inrows),floor(imcols/incols));
            newrows = inrows * scale;
            newcols = incols * scale;
            
            newim = im(1:newrows,1:newcols,:); % Crop the image to the scaled size
            
            % These are the points from the existing image
            pts = s.pts;
            
            % Scale the warped image points and the square image points.
            % These new points become the warping factors.
            spts = pts*scale;
            sqpts = obj.images.square.pts*scale;
            
            % Now, calculate the warpign coefficients for these points.
            [ac,bc] = obj.tf.warpCoefficients(spts,sqpts);
            
            % This is the hart (long) part - translate all x,y coordinates
            % in the new image to the new coordinate system
            [xI,yI] = obj.tf.TranslateCoords(ac,bc,newrows,newcols);
            
            % And, perform a bilinear interpolation on each color plane.
            Ip(:,:,1) = interp2(double(newim(:,:,1)),xI,yI,'*bilinear');
            Ip(:,:,2) = interp2(double(newim(:,:,2)),xI,yI,'*bilinear');
            Ip(:,:,3) = interp2(double(newim(:,:,3)),xI,yI,'*bilinear');
            imshow(uint8(Ip),'Border','tight');
            imout = uint8(Ip);
            
        end
        
        function [ac, bc] = DeWarp(obj,src)
            % Pick one of the images, in or out, and then get the
            % appropriate structure. Call the generic routine with the
            % image and points.
            if strcmp(src ,'in')
                s = obj.images.in;
            else
                s = obj.images.out;
            end
            
            obj.warpToSquare(s.img,s.pts);
        end
        
        function [ac, bc] = warpToSquare(obj,im,impts)
            % 
            [ac,bc] = obj.tf.warpCoefficients(obj.images.square.pts,impts);

            rows = size(im,1);
            cols = size(im,2);
            
            [xI,yI] = obj.tf.TranslateCoords(ac,bc,rows,cols);
            
            Ip = interp2(double(im),xI,yI,'*cubic');
            imshow(uint8(Ip),'Border','tight');
            
        end
        
        function [ac, bc] = warpSquare(obj,InNOut,pDir,scale)
            
            im = obj.images.square.img;
            if InNOut
                x1 = obj.images.in.pts;
                x2 = obj.images.square.pts;
                
            else
                x1 = obj.images.out.pts;
                x2 = obj.images.square.pts;
            end

            if pDir
                [ac,bc] = obj.tf.warpCoefficients(x1,x2);
            else
                [ac,bc] = obj.tf.warpCoefficients(x2,x1);
            end

            rows = floor(scale(1)*size(im,1));
            cols = floor(scale(2)*size(im,2));
            
            [xI,yI] = obj.tf.TranslateCoords(ac,bc,rows,cols);
            
            Ip = interp2(double(im),xI,yI,'*bilnear');
            imshow(uint8(Ip),'Border','tight');
        end
        
        function im = makeGridSquare(obj)
            im = 255*ones(obj.gridSize);
            
            vwidth = floor(obj.gridSize(1)/(obj.gridCells(1)+1));
            hwidth = floor(obj.gridSize(2)/(obj.gridCells(2)+1));
            gridHeight = vwidth*(obj.gridCells(1));
            gridWidth = hwidth*(obj.gridCells(2));
            gridStartRow = floor((obj.gridSize(1)-gridHeight)/2);
            gridStartCol = floor((obj.gridSize(2)-gridWidth)/2);
            rows = gridStartRow:vwidth:vwidth*(obj.gridCells(1)+1);
            cols = gridStartCol:hwidth:hwidth*(obj.gridCells(2)+1);
            for row = rows
                im(row:row+obj.gridLineWidth-1,cols(1):cols(size(cols,2))) = 0;
            end
            for col = cols
                im(rows(1):rows(size(rows,2)),col:col+obj.gridLineWidth-1) = 0;
            end
            
            x = 1;
            gridSquarePts = zeros(size(rows,2)*size(cols,2),2);
            for col = cols
                for row = rows
                    gridSquarePts(x,1) = row;
                    gridSquarePts(x,2) = col;
                    x = x + 1;
                end
            end
            obj.images.square = struct('img',uint8(im),'pts',gridSquarePts);
        end
    end
    
    methods (Access='private')
        
        function loadFiles(obj,imgPath)
            t = load('gridPts');
            gin = imread(sprintf('%s/grid_in.bmp',imgPath));
            gout = imread(sprintf('%s/grid_out.bmp',imgPath));
            obj.images.in = struct('img',gin,'pts',t.gridInPts);
            obj.images.out = struct('img',gout,'pts',t.gridOutPts);
        end
        
    end

end

