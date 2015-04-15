classdef CPerspective < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        image               % Image structure. .img is the main image, .pts
        imPath
        grid
        destPoints
        debugShow = false
        tf
    end
    
    methods
        function obj=CPerspective(varargin)
            % Pass in the path of the directory that contains the
            % images. Images are assumed to have a -N index.
            
            obj.destPoints = [];
            if length(varargin) >= 2
                impath = varargin{1};
                imname = varargin{2};
                obj.imPath = impath;
                obj.image.img = imread(sprintf('%s/%s',impath,imname));
                obj.image.imPath = impath;
                obj.image.pts = [];

            else
                obj.loadData();
                obj.setDestPoints();
            end
            % See the eTransform class for all of the transforms..
            % At least all from the time I moved them there.
            obj.tf = eTransform('perspective');
        end
        
        function pts = getInputPtsA(obj)
            close all;
            imshow(obj.gridInIm);
            pts = ginput();
        end
        
        function setDestPoints(obj)
            % Create a square that represents the destination perspective
            % points for the output. Just need to make 4 points.. needs to
            % be based on the size of the image and some trial and error.
            
            obj.destPoints = [
                800     200
                1300    200
                800     930
                1300    930
            ];
        end
        
        function loadImage(obj,path)
            obj.image = imread(path);
        end
        
        function getPoints(obj,newInputs,enScale)
            pts = obj.getInputPts(obj.image.img,'Xform',20,newInputs,enScale,'Select Alignment Points');
            obj.image.pts = pts;
        end
        
        function runTransform(obj,mDir,varargin)
            if nargin < 2
                obj.setDestPoints();
                dPts = obj.destPoints;
            else
                dPts = varargin{1};
            end
            obj.xform(mDir,obj.image,dPts);
        end
        
        function gridTransform(obj,varargin)
            if nargin < 2
                dPts = obj.grid.dpts;
            else
                dPts = varargin{1};
            end
            obj.xform(1,obj.grid,dPts);
        end
        
        function testpts(obj, spts,dpts)
            x1 = [spts(:,2) spts(:,1)];
            x2 = [dpts(:,2) dpts(:,1)];
            istruct.img = obj.image.img;
            istruct.pts = x1;
            obj.xform(istruct,x2);
        end
        
        function xform(obj,mDir,istruct,dPts)
            
            close all;
            if mDir
                x1 = istruct.pts;
                x2 = dPts;
            else
                x1 = dPts;
                x2 = istruct.pts;
            end
            
            H = obj.tf.calcPerspectiveMatrix(x2,x1);

            rows = size(istruct.img,1);
            cols = size(istruct.img,2);
            [Xi,Yi] = obj.tf.TranslateCoords(H,rows,cols);

            if size(istruct.img,3) == 3
                img1(:,:,1) = uint8(obj.tf.interp2(double(istruct.img(:,:,1)),Xi,Yi),'*bilinear');
                img1(:,:,2) = uint8(obj.tf.interp2(double(istruct.img(:,:,2)),Xi,Yi),'*bilinear');
                img1(:,:,3) = uint8(obj.tf.interp2(double(istruct.img(:,:,3)),Xi,Yi),'*bilinear');
            else
                img1 = uint8(obj.tf.interp2(double(istruct.img),Xi,Yi),'*bilinear');
            end

            
            figure(1);imshow(img1);
            
        end
        
        function imout = runTest(obj,H,spts,topleft,width,height,factor)
            dpts = topleft;
            dpts = [dpts;topleft(1) topleft(2)+height];
            dpts = [dpts;topleft(1)+width topleft(2)+height-factor*height];
            dpts = [dpts;topleft(1)+width topleft(2)+factor*height];
            spts
            dpts
            x1 = dpts;
            x2 = spts;
            N = length(x1);
            
            T = maketform('projective',x2,x1);
            B = imtransform(obj.image.img,T);
            imgB = uint8(B);
            
            sprows = 2;
            spcols = 1;
            subplot(sprows,spcols,1:spcols); imshow(imgB,'Border','tight');
            
            %imout = uint8(B);

            H = obj.tf.calcPerspectiveMatrix(x1,x2);
            Ht = T.tdata.T;
            
            id = double(obj.image.img);
            rows = size(id,1);
            cols = size(id,2);

            [Xi,Yi] = obj.tf.TranslateCoords(H',cols,rows);
            subplot(sprows,spcols,spcols+1);imshow(uint8(obj.tf.interp2(id,Xi,Yi)),'Border','tight');

            %figure;imshow(img1);
            %imout = img1;
            imout = 0;
        end
        
        function runTest2(obj,H,spts,topleft,width,height,factor)
             dpts = topleft;
            dpts = [dpts;topleft(1) topleft(2)+height];
            dpts = [dpts;topleft(1)+width topleft(2)+height-factor*height];
            dpts = [dpts;topleft(1)+width topleft(2)+factor*height];
            spts
            dpts
            x1 = dpts;
            x2 = spts;
            N = length(x1);
            
            H = obj.tf.calcPerspectiveMatrix(x1,x2);

            id = double(obj.image.img);
            rows = size(id,1);
            cols = size(id,2);

            [Xi,Yi] = obj.tf.TranslateCoords(H,cols,rows,4,4);
            figure(1);imshow(uint8(obj.tf.interp2(id,Xi,Yi)),'Border','tight');

        end
               
        function pts = getInputPts(obj,img,alignName,npts,newInputs,enScale,title)
            % getInputPts: Show the image at index n and use ginput to get
            % the points. Save the points to a file. If the points already
            % exist, use the previously saved points first... 
            fname = sprintf('%s/Image_%s',obj.imPath,alignName);
            
            if newInputs == false
                if exist(fname,'file')
                    pts = load(fname);
                end

                if exist('pts')
                    return;
                end
            end
            
            if enScale && max([size(img)]) > 1000
                % Display the image, get a rectangle, then just display
                % that rect for the alignment points.
                rect = obj.getInputPts(img,'bogus',2,1,0,'Choose a Rectangle');
                
                subimg = @(img,rect) img(rect(3):rect(4),rect(1):rect(2));
                imgt = subimg(img,rect);
                pts = obj.getInputPts(imgt,alignName,npts,1,0,title);
                
                % Now, offset by the rect size.
                pts(:,1) = pts(:,1) + rect(1);
                pts(:,2) = pts(:,2) + rect(3);
                save(fname,'pts','-ascii');
            
            else
            
                imshow(img,'Border','tight');
                h1 = gcf;
                set(h1,'MenuBar','none');
                set(h1,'NumberTitle','off');
                set(h1,'Name',title);

                figure(h1);
                pts = ginput(npts);
                save(fname,'pts','-ascii');
                
                close(h1);
            end
        end
    end
    
    methods (Access='private')
        
        function loadData(obj)
            t = load('smec');
            obj.image.img = t.smec.img;
            obj.image.pts = t.smec.pts;
            
            t = load('struct_gridsquare');
            obj.grid.img = t.img;
            obj.grid.pts = t.pts;
            obj.grid.dpts = t.dpts;
            
        end
        
    end

end

