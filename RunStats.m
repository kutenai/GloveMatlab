function RunStats(a1,a2)

    %[g1,a1] = GloveStats('GloveChar/Run1');
    %[g2,a2] = GloveStats('GloveChar/Run2');

    close all;
    plotRun(a1,1,[27 27;53 54]);
    plotRun(a2,2);

end

function plotRun(a,run,outliers)
    figure;
    plot(a.vfull);
    grid minor
    title(sprintf('Accelerometer Variance - 60 second samples, Run %d',run))
    xlabel('60 second sample number')
    ylabel('Variance')
    fname = sprintf('../Strapdown analytics/acc_run%d_var_full',run);
    print( '-dpng',fname);

    figure;
    plot(a.vhalf);
    grid minor
    title(sprintf('Accelerometer Variance - 30 second samples, Run %d',run))
    xlabel('30 second sample number')
    ylabel('Variance')
    fname = sprintf('../Strapdown analytics/acc_run%d_var_half',run);
    print( '-dpng',fname);
    
    if nargin == 3
        % Specified some outliers to exclude.
        figure;
        d = a.vhalf;
        d(outliers(2,:),:) = [];
        plot(d);
        grid minor
        title(sprintf('Accelerometer Variance with outliers removed - 30 second samples, Run %d',run))
        xlabel('30 second sample number')
        ylabel('Variance')
        fname = sprintf('../Strapdown analytics/acc_run%d_var_half_outliers',run);
        print( '-dpng',fname);

        figure;
        d = a.vfull;
        d(outliers(1,:),:) = [];
        plot(d);
        grid minor
        title(sprintf('Accelerometer Variance with outliers removed - 60 second samples, Run %d',run))
        xlabel('60 second sample number')
        ylabel('Variance')
        fname = sprintf('../Strapdown analytics/acc_run%d_var_full_outliers',run);
        print( '-dpng',fname);

    
    end
    
    figure;
    plot(a.mfull);
    grid minor
    title(sprintf('Accelerometer Mean - 60 second samples, Run %d',run))
    xlabel('60 second sample number')
    ylabel('Mean')
    fname = sprintf('../Strapdown analytics/acc_run%d_mean_full',run);
    print( '-dpng',fname);

    figure;
    plot(a.mhalf);
    grid minor
    title(sprintf('Accelerometer Mean - 30 second samples, Run %d',run))
    xlabel('30 second sample number')
    ylabel('Mean')
    fname = sprintf('../Strapdown analytics/acc_run%d_mean_half',run);
    print( '-dpng',fname);
    
    figure;
    plot(a.ifull);
    grid minor
    title(sprintf('Accelerometer Integral - 60 second samples, Run %d',run))
    xlabel('60 second sample number')
    ylabel('Integral: T*trapz(acc)/60')
    fname = sprintf('../Strapdown analytics/acc_run%d_integral_full',run);
    print( '-dpng',fname);


end
