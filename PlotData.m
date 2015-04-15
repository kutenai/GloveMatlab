classdef PlotData < handle
    %GloveData Capture and process glove data
    %   Put any methods used to manipulate the data here. Also, delegate
    %   all of the capture operations to this class. I've been splattering
    %   those around to other areas and that does not make a lot of sense.
    
    properties
        nHistory
        dWidth
        History
        currIdx
        axesList
        hPlot
    end
    
    methods
        
        function obj = PlotData(axesList,nHistory,dWidth,yLimVals)
            obj.nHistory = nHistory;
            obj.currIdx = 1;
            obj.dWidth = dWidth;
            obj.History = zeros(nHistory,dWidth);
            
            obj.axesList = axesList;
            obj.hPlot = [];
            for r = 1:3
                axes = axesList(r);
                obj.hPlot(r) = plot(axes,zeros(nHistory,1));
                xlim(axes,[0 500]);
                ylim(axes,yLimVals);
                grid(axes);
            end
        end
        
        function delete(obj)
            display('Deleting Plot Data');
        end
        
        function UpdateIndex(obj,idx)
            obj.currIdx = idx;
        end
        
        function UpdateData(obj,newData)
            obj.History = circshift(obj.History,[-1 0]);
            obj.History(end,:) = reshape(newData',1,obj.dWidth);
            obj.Replot();
        end
        
        function Replot(obj)
            offset = (obj.currIdx-1)*3;
            for r = 1:3
                set(obj.hPlot(r),'Ydata',obj.History(:,offset+r));
            end
        end
    end
    
end

