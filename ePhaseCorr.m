classdef ePhaseCorr < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enHamming = false
        debugShow = false
        verbose = false
    end
    
    methods
        function obj = ePhaseCorr
            obj.enHamming = false;
        end
        
        function [dr,dc] = calcoffset(obj,im1,im2)
            
            [in1,in2] = obj.normalize(im1,im2);
            [dr,dc] = obj.phasecorr(in1,in2);
            
        end
        
        function [dr,dc] = xcorr(obj,rect1,rect2)
            c = normxcorr2(rect1,rect2);
            %figure, surf(c), shading flat;
            [max_c,imax] = max(abs(c(:)));
            [ypeak, xpeak] = ind2sub(size(c),imax(1));
            corr_offset = [(xpeak-size(rect1,2)) (ypeak-size(rect1,1))];
            dc = corr_offset(1);
            dr = corr_offset(2);
        end
        
        function [dr,dc] = phasecorr(obj,im1,im2)
            % Take 2D fft of both images
            
            if obj.enHamming
                h = obj.mkfilt();
                him1 = imfilter(im1,h,'same');
                him2 = imfilter(im2,h,'same');
            else
            
                % Disable filtering.. not working as desired.
                him1 = im1;
                him2 = im2;
            end
            
            if obj.debugShow
                figure;imshow(him1);
                figure;imshow(him2);
            end

            
            % Take FFT of both images.
            f1 = (fft2(double(him1)));
            f2 = (fft2(double(him2)));
            
            % Calculate the cross power spectrum
            prod1 = f1.*conj(f2);
            cps = prod1./abs(prod1);
            % Take inverse fft of power spectrum
            ncc = ifft2(cps);
            ancc = abs(ncc); % Take magnitude
            
            % Find max point
            ancc(1,1) = 0;
            [cmax,imax] = max(ancc(:));
            [ypeak, xpeak] = ind2sub(size(ancc),imax(1));
            corr_offset = [(xpeak-size(him1,2)) (ypeak-size(him1,1))];
            %dr = -1 * corr_offset(1);
            %dc = -1 * corr_offset(2);
            dc = xpeak;
            dr = ypeak;
            obj.display(sprintf('PC Values Dr:%d Dc:%d',dr,dc));
            
            % Perform some scaling if the shift  "should" be negative.
            [r,c] = size(him1);
            if dr > r/2
                dr = dr-r;
            end
            if dc > c/2
                dc = dc-c;
            end
            %dr = (r/2)-dr;
            %dc = 0.5*dc;
            obj.display(sprintf('Offset Dr:%d Dc:%d',dr,dc));
            
            if obj.debugShow
                figure, surf(abs(ncc)), shading flat;
            end
        end
        
        function [im1,im2] = normalize(obj,im1,im2)
            % assume that im1 is the base image
            % im2 might be smaller (generally will)
            % so need to copy it to a blank canvas with all zeros
            
            % compensate for color or gray.
            [r1,c1,d1] = size(im1);
            [r2,c2,d2] = size(im2);
            
            if d1 > 1
                im1 = rgb2gray(im1);
            end
            if d2 > 1
                im2 = rgb2gray(im2);
            end
            
            ro = max(r1,r2);
            co = max(c1,c2);
            
            
            if r1 < ro || c1 < co
                % pad the image if it is smaller
                itmp = uint8(zeros(ro,co));
                itmp(1:r1,1:c1) = im1;
                im1 = itmp;
            end
            
            if r2 < ro || c2 < co
                % pad the image if it is smaller
                itmp = uint8(zeros(ro,co));
                itmp(1:r2,1:c2) = im2;
                im2 = itmp;
            end
            
        end
        
        function h = mkfilt(obj)
            sz = 21;
            [f1,f2] = freqspace(sz,'meshgrid');
            Hd = ones(sz); 
            r = sqrt(f1.^2 + f2.^2);
            Hd((r<0.01)|(r>0.5)) = 0;
            h = fwind1(Hd,hamming(sz));
        end
        
        function i1 = copyNonZero(obj,i1,i2,rs,cs)
            [r,c,d] = size(i2);
            zero = zeros(d,1);
            
            for x=rs:rs+r-1
                xs = x - rs + 1;
                for y=cs:cs+c-1
                    ys = y-cs+1;
                    if all(i2(xs,ys,:) ~= 0)
                        i1(x,y,:) = i2(xs,ys,:);
                    end
                end
            end
        end
        
        function [im,im2center] = stitch(obj,im1,im2,dr,dc)
            [r1,c1,planes1] = size(im1);
            [r2,c2,planes2] = size(im2);
            
            if dr < 0
                r1start = -dr;
                r2start = 1;
                rsize = r1 + abs(dr);
            else
                r1start = 1;
                r2start = dr+1;
                rsize = max(r1,r2+dr);
            end
            if dc < 0
                c1start = -dc;
                c2start = 1;
                csize = c1 + abs(dc);
            else
                c1start = 1;
                c2start = dc+1;
                csize = max(c1,c2+dc);
            end
            itemp = zeros(rsize,csize,planes1);
            %itemp = obj.copyNonZero(itemp,im2,r2start,c2start);
            %itemp = obj.copyNonZero(itemp,im1,r1start,c1start);
            
            itemp(r1start:r1start+r1-1,c1start:c1start+c1-1,:) = im1;
            itemp2 = zeros(rsize,csize,planes1);
            itemp2(r2start:r2start+r2-1,c2start:c2start+c2-1,:) = im2;
            
            figure;
            h = imshow(uint8(itemp),'Border','tight');
            mask = ones(rsize,csize);
            i =find(itemp(:,:,1) == 0);
            mask(i) = 0;
            set(h,'AlphaData',mask);
            hold on;

            h1 = imshow(uint8(itemp2),'Border','tight');
            mask2 = ones(rsize,csize);
            i =find(itemp2(:,:,1) == 0);
            mask2(i) = 0;
            set(h1,'AlphaData',mask2);

            hold off;
            
            I = getframe(gcf);
            imdata = I.cdata;
            
            im = rgb2gray(imdata);
            
            im2center = [r2start c2start];
            
        end
        
        function [im] = stitchraw(obj,im1,im2,dr,dc)
            [r1,c1,planes1] = size(im1);
            [r2,c2,planes2] = size(im2);
            
            if dr < 0
                r1start = -dr;
                r2start = 1;
                rsize = r1 + abs(dr);
            else
                r1start = 1;
                r2start = dr+1;
                rsize = max(r1,r2+dr);
            end
            if dc < 0
                c1start = -dc;
                c2start = 1;
                csize = c1 + abs(dc);
            else
                c1start = 1;
                c2start = dc+1;
                csize = max(c1,c2+dc);
            end
            itemp = zeros(rsize,csize,planes1);
            itemp = obj.copyNonZero(itemp,im2,r2start,c2start);
            itemp = obj.copyNonZero(itemp,im1,r1start,c1start);
            
            im = uint8(itemp);
        end
        
        function display(obj,s)
            if obj.verbose
                display(s);
            end
        end
    end
    
end

