classdef GloveGuiBase < GuiBase
    % GloveGuiBase Extend the GuiBase class with Glove specicif code.
    % This class exends the GuiBase and builds a glove GUI.
    
    properties

        positions
        
        % GloveData object - contains the capture and manipulation code
        gData
        
        plotObjs
        posIndex
                
    end
    
    methods
        function obj = GloveGuiBase()
            % Constructor. Takes as an argument the
            % video processing object which contains the images and such.
            
            obj.InitGui();
            obj.plotObjs = {};
            obj.InitPlotObjects();
            
            obj.gData = GloveData();
            obj.posIndex = 1;
        end
        
        function delete(obj)
            % Clean up anything that needs to be fixed up. Close timers,
            % close the data capture, etc.
            
            display('Deleting GloveGuiBase.');
            
            try
                for x = 1:size(obj.plotObjs,2)
                    delete(obj.plotObjs{x})
                end
            catch e
            end
            
            try
                clear(obj.imuObj);
                clear(obj.gData);
                %obj.gData.StopCapture();
            catch e
            end
        end
        
        function InitGui(obj)
            % Build the GUI. Note that the callbacks are for this object.
            % The size is fixed.. should query the screen size or
            % something..
            % I store all of the UI handles into a .ui parameter of this
            % object.
            
            figWidth = 1200;
            figHeight = 580;
            
            panelWidth = 0.2;
            panelLeft = 1 - panelWidth;
            obj.ui.Figure = figure(...
                'Visible','Off',...
                'Colormap',gray(256),...
                'Position',[100 100 figWidth figHeight]);
            
            set(obj.ui.Figure,...
                'KeyPressFcn',@(src,event)keypress_cb(obj,src,event));
            
            obj.ui.hPanelCtrl = uipanel('Title','Controls','FontSize',12,...
                'Parent',obj.ui.Figure,...
                'Units','normalized',...
                'Position',[panelLeft 0 panelWidth 1]);
            
            % Add one axes for the image display,
            % then add a tile of 6 axes for the Gyro and Acc data display,
            % these are 2 columns by 3 rows... finally, we have the panel
            
            obj.ui.plotWidth = panelLeft;
            obj.ui.plotLeft = 0;
            obj.ui.plotMargin = 0.02;
            obj.ui.plotVertMargin = 0.08;
            obj.ui.dataWidth = obj.ui.plotWidth/2;
            
            panelIdx = 0;
            obj.ui.hPanelGyro  = obj.AddTripleGraph('GyroAxes',[0 0 panelWidth 1],'Gyro','Gyro Axes');
            obj.ui.hPanelAcc   = obj.AddTripleGraph('AccAxes',[panelWidth 0 panelWidth 1],'Accelerometer','Accelerometer Axes');
            obb.ui.hPanelV     = obj.AddTripleGraph('VAxes',[2*panelWidth 0 panelWidth 1],'Velocity','Velocity Axes');
            obu.ui.hPanelPos   = obj.AddTripleGraph('PAxes',[3*panelWidth 0 panelWidth 1],'Position','Position Axes');
           
            editPos = 0;
            
            obj.ui.btnClose= obj.AddButton(...
                'Close',...
                0,...
                @(src,event)btnClose_cb(obj,src,event)...
            );
            obj.ui.startLive= obj.AddToggleButton(...
                'Start Live',...
                1,...
                @(src,event)startLive_cb(obj,src,event)...
            );
            obj.AddEditText('Data Check','1',2);
            obj.AddTable('DCM',eye(3),3,3);
            
            % Build a menu of the data sets and populate it with
            % a list of all of the data set names.

            mnu2 = uimenu('Label','Positions');
            obj.positions = {'Hand','Middle','Ring','Thumb','Pinkie','Index'};
            acc = {'1','2','3','4','5','6'};
            for k = 1:length(obj.positions)
                uimenu(mnu2,'Label',obj.positions{k},...
                    'Callback',@(src,event)positionMenu_cb(obj,k),...
                    'Accelerator',acc{k});
            end
            
            obj.AddComboBox('Position',obj.positions,6,2);
            h = obj.ui.list('Position').list;
            set(h,'Callback',@(src,event)positionsCombo_cb(obj,src,event));
                
            set(obj.ui.Figure,'Name','Gyro Glove Data Visualizer');
            
            % Make the GUI visible.
            set(obj.ui.Figure,'Visible','on');
            set(obj.ui.hPanelCtrl,'Visible','on');
        end
        
        function InitPlotObjects(obj)
            obj.plotObjs{1} = PlotData(obj.ui.GyroAxes, 500, 18,...
                [-500*2*pi/360 500*2*pi/360]);
            obj.plotObjs{2} = PlotData(obj.ui.AccAxes, 500, 18,[-2 2]);
            obj.plotObjs{3} = PlotData(obj.ui.VAxes, 500, 18,[-5 5]);
            obj.plotObjs{4} = PlotData(obj.ui.PAxes, 500, 18,[-180 180]);
        end

        function IMUPlot(obj,acc,gyro)
            obj.plotObjs{1}.UpdateData(gyro);
            obj.plotObjs{2}.UpdateData(acc);
            obj.plotObjs{3}.UpdateData(obj.imuObj.Velocities());
            %obj.plotObjs{4}.UpdateData(obj.imuObj.Positions());
            obj.plotObjs{4}.UpdateData(obj.imuObj.EulerAngles());
        end
                
        function StartLive(obj,periodms)
        end
        
        function StopLive(obj)
        end
        
        function positionMenu_cb(obj,posIndex)
            % Called by the menu item to update the index that selects
            % which IMU dataset to display on the graphs.
            obj.posIndex = posIndex;
            for x = 1:size(obj.plotObjs,2)
                obj.plotObjs{x}.UpdateIndex(posIndex)
            end
            display(sprintf('Updated position to %d',posIndex));
            h = obj.ui.list('Position').list;
            set(h,'Value',obj.posIndex);
        end
        
        function positionsCombo_cb(obj,src,event)
            % Called by the menu item to update the index that selects
            % which IMU dataset to display on the graphs.
            
            posIndex = get(src,'Value');
            obj.posIndex = posIndex;
            for x = 1:size(obj.plotObjs,2)
                obj.plotObjs{x}.UpdateIndex(posIndex)
            end
            display(sprintf('Updated position to %d',posIndex));
        end
        
        function startLive_cb(obj,src,event)
            if get(src,'Value') == get(src,'Max')
                obj.StartLive(40);
            else
                obj.StopLive();
            end
        end
        
        function btnClose_cb(obj,src,event)
            close(gcbf);
            obj.delete;
        end
        
        function keypress_cb(obj,src,event)
            if event.Character == 'r'
                % restart
                obj.Restart();
            elseif event.Character == 'z'
                obj.Zero();
            end
        end
        
        % Functions to override.
        function Restart(obj)
        end
        function Zero(obj)
        end
    end
    
end


