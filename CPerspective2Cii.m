classdef CPerspective2Cii < handle
    %CPerspective2Cii Implement a mosaic algorithm
    %   Implementation an algorithm to perspective transform a sequence of
    %   images and then stich them together using a phase correlation or
    %   similar method. 
    

    properties
        imageList               % Image structure. .img is the main image, .pts
        imPath
        imageAligned
        imageStitched
        debugShow = false
        tf
        tfpc
    end
    
    methods (Static)
    end
    
    methods
        function obj=CPerspective2Cii(imPath)
            % Pass in the path of the directory that contains the
            % images. Images are assumed to have a -N index.
            
            obj.imPath = imPath;
            obj.loadFiles(imPath);
            obj.imageAligned = containers.Map();
            obj.imageStitched = containers.Map();
            % See the eTransform class for all of the transforms..
            % At least all from the time I moved them there.
            obj.tf = eTransform('perspective');
            obj.tfpc = ePhaseCorr();
        end
        
        function reset(obj)
            obj.perspectiveAlign(1,2);
            obj.stitchv2(1,2);

            obj.perspectiveAlign(2,3);
            obj.stitchv2(2,3);

            %obj.perspectiveAlign(3,4);
            %obj.stitchv2(3,4);
        end
        
        function save(obj)
            imageAligned = obj.imageAligned;
            imageStitched = obj.imageStitched;
            
            save('matlab/CPerspective2Cii_save','imageAligned','imageStitched');
        end
        
        function restore(obj)
            t = load('matlab/CPerspective2Cii_save');
            obj.imageAligned = t.imageAligned;
            obj.imageStitched = t.imageStitched;
        end
        
        function showStiched(obj,n1,n2)
            rn = @(a,b) sprintf('Register_%d_to_%d',a,b);
            if isKey(obj.imageStitched,rn(n1,n2))
                s = obj.imageStitched(rn(n1,n2));
                figure;imshow(s.img);
                figure;imshow(s.im1.img);
                figure;imshow(s.im2.img);
            end

        end
        
        function showPMatched(obj,n1,n2)
            an = @(a,b) sprintf('Aligned_%d_to_%d',a,b);
            if isKey(obj.imageAligned,an(n1,n2))
                s = obj.imageAligned(an(n1,n2));
                figure;imshow(s.img);
                figure;imshow(s.img1.img);
                figure;imshow(s.img2.img);
            end

        end
        
        function showAllImages(obj)
            % Just a function to mosaic the images.
            N = length(obj.imageList);
            [r,c,d] = size(obj.imageList{1});
            I = zeros([r c d N]);
            for x = 1:length(obj.imageList)
                I(:,:,:,x) = obj.imageList{x};
            end
            
            montage(uint8(I));
        end
        
        function [dr,dc] = xcorr(obj,in1,in2)
            c = normxcorr2(in1,in2);
            % offset found by correlation
            [max_c, imax] = max(abs(c(:)));
            [ypeak, xpeak] = ind2sub(size(c),imax(1));
            corr_offset = [(xpeak-size(sub_onion,2))
                           (ypeak-size(sub_onion,1))];

            % relative offset of position of subimages
            rect_offset = [(rect_peppers(1)-rect_onion(1))
                           (rect_peppers(2)-rect_onion(2))];

            % total offset
            offset = corr_offset + rect_offset;
            xoffset = offset(1);
            yoffset = offset(2);            
            
            dc = xoffset;
            dr = yoffset;
        end
        
        function [r1,r2,offset] = normalizeRects(obj, i1, i2)
            % We need these rectangles to be the same size,
            % but they cannot extend beyond the extents of their
            % respective images
            % We need to return the relative position of the two rectangles
            % as a shift of rectangle b relative to a
            
            [rows1, cols1, d1] = size(i1.img);
            [rows2, cols2, d2] = size(i2.img);
            
            r1 = i1.rect;
            r2 = i2.rect;
            
            % Local funcs
            w = @(r) r(2)-r(1);
            h = @(r) r(4)-r(3);

            w1 = w(r1);
            h1 = h(r1);
            w2 = w(r2);
            h2 = h(r2);
            
            if w2 > w1
                d = w2-w1;
                if r1(2)+d < cols1
                    % Expand to right if possible
                    r1(2) = r1(2)+d;
                else
                    % To left otherwise.
                    r1(1) = r1(1)-d;
                end
            elseif w1 > w2
                d = w1-w2;
                if r2(2)+d < cols2
                    % Expand to right if possible
                    r2(2) = r2(2)+d;
                else
                    % To left otherwise.
                    r2(1) = r2(1)-d;
                end
            end
            
            if h2 > h1
                d = h2-h1;
                if r1(4)+d < rows1
                    % Expand down if possible
                    r1(4) = r1(4)+d;
                else
                    % up otherwise.
                    r1(3) = r1(3)-d;
                end
            elseif h1 > h2
                d = h1-h2;
                if r2(4)+d < rows2
                    % Expand down if possible
                    r2(4) = r2(4)+d;
                else
                    % up otherwise.
                    r2(3) = r2(3)-d;
                end
            end
            
            offset = [r1(3)-r2(3) r1(1)-r2(1)];
            
        end
        
        function stitch(obj,n1,n2,newInputs)
            
            % If there is a stiched image for n1, then we should use that
            % instead..
            
            % These are "anonymous functions" They basically allow me to
            % write short simple local code that is used repeatedly.. in a
            % concise way. rn(1,2) results in a string "Register_1_to_2"
            % for example
            rn = @(a,b) sprintf('Register_%d_to_%d',a,b);
            an = @(a,b) sprintf('Aligned_%d_to_%d',a,b);

            % This is a bit diecy.. what do we stich to?
            % lets say we are stitching Image1 to Image2.. 
            % Has Image1 been aligned to Image2? If so, we want to use the
            % aligned version.. stored in imageAligned under
            if isKey(obj.imageAligned,an(n1,n2))
                ia = obj.imageAligned(an(n1,n2));
                if ia.mDir == 0
                    i1.img = ia.img1.img;
                    i2.img = ia.img;
                else
                    i1.img = ia.img;
                    i2.img = ia.img2.img;
                end
            else
                error('Cannot stitch images unless they have been aligned.');
                return;
            %elseif isKey(obj.imageStitched,rn(n1-1,n1))
                %i1 = obj.imageStitched(rn(n1-1,n1));
                %i2.img = obj.imageList{n2};
            end
            
            
            % Do not normalize, instead, make two rectangles of the same
            % size. The rectangles will encompass all of the points in the
            % phase alignment points.. so, they should contain the parts of
            % the images that need to be phase aligned.
            
            [i1.rect,i2.rect] = obj.getInputPts(i1.img,n1,i2.img,n2,rn(n1,n2),2,newInputs,1,'Select Rectangles');
            
            % Normalize the rectangle sizes
            % also return the offset between these - this is the
            % base shift, then we shift +- based on the phase correlation.
            [r1,r2,offset] = obj.normalizeRects(i1,i2);
            i1.rect = r1;
            i2.rect = r2;
            
            imrect = @(im) im.img(im.rect(3):im.rect(4),im.rect(1):im.rect(2));
            in1 = imrect(i1);
            in2 = imrect(i2);
            
            [dr,dc] = obj.tfpc.phasecorr(in1,in2);
            %[cdr, cdc] = obj.xcorr(in1,in2);
            %obj.montagePair(in1,in2);
            odr = round(offset(1)+dr);
            odc = round(offset(2)+dc);
            if obj.debugShow
                figure;
                imshow(i1.img,'Border','tight');
                figure;
                imshow(i2.img,'Border','tight');
            end
            ims = obj.tfpc.stitchraw(i1.img,i2.img,odr,odc);
            
            stitched.img = ims;
            stitched.ia = ia;
            stitched.im1 = i1;
            stitched.im2 = i2;
            stitched.offset = offset;
            stitched.dr = dr;
            stitched.dc = dc;
            stitched.odr = odr;
            stitched.odc = odc;
            
            obj.imageStitched(rn(n1,n2)) = stitched;
            
            if obj.debugShow
                figure;
                imshow(ims,'Border','tight');
            end
        end
        
        function perspectiveAlign(obj,n1,n2,mDir,newInputs)
            % Function takes two numbers, which are assumed to be
            % indexes into the internal array of images.
            % I expect this function to be called by some iterative
            % function.. but for now, it will manually use gInput to align
            % the perspective.
            
            % These are "anonymous functions" They basically allow me to
            % write short simple local code that is used repeatedly.. in a
            % concise way. rn(1,2) results in a string "Register_1_to_2"
            % for example
            rn = @(a,b) sprintf('Register_%d_to_%d',a,b);
            an = @(a,b) sprintf('Aligned_%d_to_%d',a,b);

            if isKey(obj.imageStitched,rn(n1-1,n1))
                i1 = obj.imageStitched(rn(n1-1,n1));
            else
                i1.img = obj.imageList{n1};
            end
            
            if isKey(obj.imageStitched,rn(n2,n2+1))
                i2 = obj.imageStitched(rn(n2,n2+1));
            else
                i2.img = obj.imageList{n2};
            end

            % Display both images, use ginput go grab a set of alignment
            % points from each image. If newInputs == false and there are
            % existing alignment points, re-use those.. save time when
            % tweaking algorithms.
            [i1.pts,i2.pts] = obj.getInputPts(i1.img,n1,i2.img,n2,an(n1,n2),20,newInputs,1,'Select Alignment Points');

            [pmatch] = obj.perspectiveMatch(i1,i2,mDir);
            
            % Store the result.
            pmatch.n1 = n1;
            pmatch.n2 = n2;
            obj.imageAligned(an(n1,n2)) = pmatch;
        end
        
        function [pmatch] = perspectiveMatch(obj,i1,i2,mDir)
            % Input: two structures, with .img containing the image data
            % and .pts the points for that image. It is assumed that the
            % points on image 1 and image 2 are intended to align each
            % other.
            
            % I need to swap the points.. this will transform
            % image 2 to have the same perspective as image 1...
            % Allow the match to be done left to right or right to left.
            if mDir == 0 % i2 -> i1
                x1 = i1.pts;
                x2 = i2.pts;
                itrans = i2.img;
            else
                x1 = i2.pts;
                x2 = i1.pts;
                itrans = i1.img;
            end
            
            assert(all(size(x1) == size(x2)));
            
            N = length(x1);

            H = obj.tf.calcPerspectiveMatrix(x1,x2);

            [rows,cols,dims] = size(itrans);
            [Xi,Yi] = obj.tf.TranslateCoords(H,rows,cols);

            if size(i1.img,3) == 3
                img1(:,:,1) = uint8(obj.tf.interp2(double(itrans(:,:,1)),Xi,Yi),'*bilinear');
                img1(:,:,2) = uint8(obj.tf.interp2(double(itrans(:,:,2)),Xi,Yi),'*bilinear');
                img1(:,:,3) = uint8(obj.tf.interp2(double(itrans(:,:,3)),Xi,Yi),'*bilinear');
            else
                img1 = uint8(obj.tf.interp2(double(itrans),Xi,Yi),'*bilinear');
            end
            
            if obj.debugShow

                % Montage all three if I can.. otherwise just two.
                if all(size(i1.img) == size(img1)) && all(size(i2.img) == size(img1))
                    N = 3;
                    [r,c,d] = size(i1.img);
                    I = zeros([r c d N]);
                    I(:,:,:,1) = i1.img;
                    I(:,:,:,2) = i2.img;
                    I(:,:,:,3) = img1;

                    montage(uint8(I));
                else
                    if all(size(i1.img) == size(i2.img))
                        obj.montagePair(i1.img,i2.img);
                    else
                        figure;
                        imshow(i1.img);
                        figure;
                        imshow(i2.img);
                    end
                    figure;
                    imshow(img1,'Border','tight');
                end
            end
            
            pmatch.mDir = mDir;
            pmatch.img = img1;
            pmatch.img1 = i1;
            pmatch.img2 = i2;
            pmatch.H  = H;
        end
        
        function montageN(obj,ilist)
            for n = 1:length(ilist)
            end
        end
        
        function montagePair(obj,i1, i2)
            % Form a montage of 2 images for easy viewing.
            
            assert(all(size(i1) == size(i2)));
            
            N = 2;
            [r,c,d] = size(i1);
            I = zeros([r c d N]);
            I(:,:,:,1) = i1;
            I(:,:,:,2) = i2;
            
            montage(uint8(I));
        end
        
        function [pts1,pts2] = getInputPts(obj,img1,n1,img2,n2,alignName,npts,newInputs,enScale,title)
            % getInputPts: Show the image at index n and use ginput to get
            % the points. Save the points to a file. If the points already
            % exist, use the previously saved points first... 
            fname1 = sprintf('%s/Image_%d_%s',obj.imPath,n1,alignName);
            fname2 = sprintf('%s/Image_%d_%s',obj.imPath,n2,alignName);
            
            if newInputs == false
                if exist(fname1,'file')
                    pts1 = load(fname1);
                end

                if exist(fname2,'file')
                    pts2 = load(fname2);
                end

                if exist('pts1') && exist('pts2') 
                    return;
                end
            end
            
            if enScale && max([size(img1) size(img2)]) > 1000
                % Display the image, get a rectangle, then just display
                % that rect for the alignment points.
                [rect1,rect2] = obj.getInputPts(img1,n1,img2,n2,'bogus',2,1,0,'Choose a Rectangle');
                
                subimg = @(img,rect) img(rect(3):rect(4),rect(1):rect(2));
                img1t = subimg(img1,rect1);
                img2t = subimg(img2,rect2);
                [pts1,pts2] = obj.getInputPts(img1t,n1,img2t,n2,alignName,npts,1,0,title);
                
                % Now, offset by the rect size.
                pts1(:,1) = pts1(:,1) + rect1(1);
                pts1(:,2) = pts1(:,2) + rect1(3);
                save(fname1,'pts1','-ascii');
            
                pts2(:,1) = pts2(:,1) + rect2(1);
                pts2(:,2) = pts2(:,2) + rect2(3);
                save(fname2,'pts2','-ascii');
            else
            
                imshow(img1,'Border','tight');
                h1 = gcf;
                set(h1,'MenuBar','none');
                set(h1,'NumberTitle','off');
                set(h1,'Name',title);

                figure;
                h2 = gcf;
                imshow(img2,'Border','tight');
                set(h2,'MenuBar','none');
                set(h2,'NumberTitle','off');
                set(h2,'Name',title);

                figure(h1);
                pts1 = ginput(npts);
                save(fname1,'pts1','-ascii');
                
                npts = size(pts1,1);

                figure(h2);
                pts2 = ginput(npts);
                save(fname2,'pts2','-ascii');

                close(h1);
                close(h2);
            end
        end
    end
    
    methods (Access='private')
        
        function loadFiles(obj,imgPath)
            % Load a set of images from the specified path.
            % Images are loaded and then ordered by number.
            % This assumes that the iamges are "name_nn.jpg",
            % so that the number can be used as a sequence.

            % The dir command will not preserve order.
            % Load the files, get the name, find the number
            % and then convert to a value.. store the image
            % into a data structure indexed by the numeric value
            do = dir(sprintf('%s/*jpg',imgPath));
            do = [do;dir(sprintf('%s/*png',imgPath))];
            for x=1:length(do);
                fname = do(x).name;
                [a,b] = regexp(fname,'(\d+).(jpg|png)','tokens');
                t1 = a{1,1}{1};
                flist{str2num(t1),1} = do(x).name;
            end

            % Save the images into an internal data structure.
            for x=1:size(flist,1)
                f = flist{x};
                nm = sprintf('%s/%s',imgPath,f);

                im = imread(nm);
                obj.imageList{x,1} = im;
            end

        end
        
    end

end

