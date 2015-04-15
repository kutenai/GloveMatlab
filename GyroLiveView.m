function GyroLiveView(numToRead)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    figureHandle = figure('NumberTitle','off',...
        'Name','Gyro Glove');

    %%
    % Setup the axes 
    h1 = subplot(3,1,1);
    h2 = subplot(3,1,2);
    h3 = subplot(3,1,3);
    
    set(h1,...
        'YGrid','on',...
    
    'XGrid','on');
    
    set(h2,...
        'YGrid','on',...
        'XGrid','on');
    
    set(h3,...
        'YGrid','on',...
        'XGrid','on');
    
    xlabel(h1,'Number of Samples');
    ylabel(h1,'Value');
    xlabel(h2,'Number of Samples');
    ylabel(h2,'Value');
    xlabel(h3,'Number of Samples');
    ylabel(h3,'Value');

    %set(subplot(3,1,1),'Color','black');
    %set(subplot(3,1,2),'Color','black');
    %set(subplot(3,1,3),'Color','black');
    %set(gca,'Color','black');

    %%
    % Initialize the plot and hold the settings on
    hold on;
    plotHandle1 = plot(h1,0,'-r','LineWidth',1);
    plotHandle2 = plot(h2,0,'-g','LineWidth',1);
    plotHandle3 = plot(h3,0,'-b','LineWidth',1);

    GyroGloveCapture({'connect'});
    GyroGloveCapture({'start'});
    allvals = zeros(200,3,'int16');
    set(plotHandle1,'Ydata',allvals(:,1));
    set(plotHandle2,'Ydata',allvals(:,2));
    set(plotHandle3,'Ydata',allvals(:,3));
    n = 1;
    tStart = tic;
    theta = 0;
    while n < numToRead
        if numToRead - n < 10
            nRequest = numToRead - n;
        else
            nRequest = 10;
        end
        nRequest = 2;

        [vals,cnt] = GyroGloveCapture({'recv',nRequest});
        if cnt > 0
            if n > 500
                allvals = [allvals(1+cnt:500,1:3);vals(1:cnt,2:4)];
            else
                allvals(n:n+cnt-1,1:3) = vals(1:cnt,2:4);
            end
            n = n + cnt;
            set(plotHandle1,'Ydata',allvals(:,1));
            set(plotHandle2,'Ydata',allvals(:,2));
            set(plotHandle3,'Ydata',allvals(:,3));
            GyroGloveClient(0,[0 0 1 0 theta 0])
            %display(sprintf('Count:%d',cnt));
            theta = 360*mod(n,1000)/1000;
            %drawnow;
        else
            pause(0.01);
        end
    end
    tElapsed = toc(tStart);
    display(sprintf('Elapsed time:%f',tElapsed));
    GyroGloveCapture({'stop'});
    GyroGloveCapture({'close'});



end

