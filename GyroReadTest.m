
numToRead = 1000;
GyroGloveCapture({'connect'});
GyroGloveCapture({'start'});
allvals = zeros(numToRead,55,'int16');
n = 1;
tStart = tic;
while n < numToRead
    if numToRead - n < 10
        nRequest = numToRead - n;
    else
        nRequest = 10;
    end
        
    [vals,cnt] = GyroGloveCapture({'recv',nRequest});
    if cnt > 0
        allvals(n:n+cnt-1,:) = vals(1:cnt,:);
        n = n + cnt;
    else
        pause(0.01);
    end
end
tElapsed = toc(tStart);
display(sprintf('Elapsed time:%f',tElapsed));
GyroGloveCapture({'stop'});
GyroGloveCapture({'close'});


