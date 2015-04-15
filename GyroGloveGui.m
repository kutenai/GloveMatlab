classdef GyroGloveGui < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        dataSetName
        dataPath
        matName
        mp4Name
        
        dataSets
        currDataSet
        currDataIndex
        positions
        
        ui
        vp
        results
        dataFrame
        axesDisplay
        curr_idx
                
    end
    
    methods
        function obj = GyroGloveGui(dataPath)
            % Constructor. Takes as an argument the
            % video processing object which contains the images and such.
            obj.dataPath = dataPath;
            obj.LoadDataFiles();
            
            obj.InitGui();
        end
        
        function delete(obj)
            % This does not do much.. I was thinking I would add some stuff
            % here.
            display('Deleting the object.');
        end
        
        function LoadDataFiles(obj)
            files = dir([obj.dataPath '*.mat']);

            obj.dataSets = struct();

            for k = 1:size(files,1)
                f = files(k);
                [pathstr,name,ext] = fileparts(f.name);
                %disp (f.name);
                
                t = load([obj.dataPath f.name]);
                
                obj.dataSets.(name) = struct();
                tstruct = struct();
                tstruct.name = name;
                tstruct.matfile = [obj.dataPath f.name];
                
                if isfield(t,'Data')
                    tstruct.('data') = t.Data;
                else
                    fn = fieldnames(t);
                    field = fn{1};
                    tstruct.('data') =getfield(t,field);
                end

                if isfield(t,'T')
                    tstruct.('T') = t.T;
                else
                    % This is the default for old data that did not specify
                    % otherwise
                    tstruct.('T') = 1/180;
                end
                
                mp4name = [obj.dataPath name '_DI.mp4'];
                if exist(mp4name,'file') == 2
                    tstruct.mp4name = mp4name;
                end
                
                obj.dataSets.(name) = tstruct;
            end
            
            % Set the current dataset to the first field
            fn = fieldnames(obj.dataSets);
            obj.currDataSet = fn{1};
            obj.positions = {'Hand','Thumb','Index','Middle','Ring','Pinkie'};
            obj.currDataIndex = 1;
        end
        
        function InitGui(obj)
            % Build the GUI. Note that the callbacks are for this object.
            % The size is fixed.. should query the screen size or
            % something..
            % I store all of the UI handles into a .ui parameter of this
            % object.
            
            figWidth = 1200;
            figHeight = 580;
            obj.ui = struct();
            
            obj.ui.panelWidth = 0.25;
            obj.ui.panelLeft = 1 - obj.ui.panelWidth;
            obj.ui.Figure = figure(...
                'Visible','Off',...
                'Colormap',gray(256),...
                'Position',[100 100 figWidth figHeight]);
            
            obj.ui.Panel = uipanel('Title','Controls','FontSize',12,...
                'Parent',obj.ui.Figure,...
                'Units','normalized',...
                'Position',[obj.ui.panelLeft 0 obj.ui.panelWidth 1]);
                
            
            % Add one axes for the image display,
            % then add a tile of 6 axes for the Gyro and Acc data display,
            % these are 2 columns by 3 rows... finally, we have the panel
            obj.ui.axesHeight = 1;
            
            obj.ui.plotWidth = obj.ui.panelLeft;
            obj.ui.plotLeft = 0;
            obj.ui.plotMargin = 0.02;
            obj.ui.plotVertMargin = 0.08;
            obj.ui.dataWidth = obj.ui.plotWidth/2;
            obj.ui.dataHeight = obj.ui.axesHeight/3;
            
            % Define the Gyro Axes
            xyz = {'Gyro X', 'Gyro Y', 'Gyro Z'};
            for r = 1:3
                % Left is always just right of the Video Axes.
                % Bottom is 2/3, 1/3 and 0/3
                % Width and height are fixed.
                aop = [...
                    obj.ui.plotLeft+obj.ui.plotMargin ...
                    (3-r)*obj.ui.dataHeight+obj.ui.plotVertMargin ...
                    obj.ui.dataWidth - 2 * obj.ui.plotMargin ...
                    obj.ui.dataHeight-2*obj.ui.plotVertMargin];
                ap = aop;
                obj.ui.GyroAxes(r) = axes(...
                        'DataAspectRatio', [1 1 1],...
                        'DrawMode','fast',...
                        'Visible','on',...
                        'OuterPosition',aop,...
                        'Position',ap,...
                        'Parent', obj.ui.Figure);
                title(obj.ui.GyroAxes(r),'Gyro Axes');
            end
           
            % Define the Accelerometer Axes
            xyz = {'Acelerometer X', 'Acelerometer Y', 'Acelerometer Z'};
            for r = 1:3
                % Left is always just right of the Video Axes.
                % Bottom is 2/3, 1/3 and 0/3
                % Width and height are fixed.
                aop = [...
                    obj.ui.plotLeft+obj.ui.dataWidth+obj.ui.plotMargin ...
                    (3-r)*obj.ui.dataHeight+obj.ui.plotVertMargin ...
                    obj.ui.dataWidth - 2 * obj.ui.plotMargin ...
                    obj.ui.dataHeight-2*obj.ui.plotVertMargin];
                ap = aop;
                obj.ui.AccAxes(r) = axes(...
                        'DataAspectRatio', [1 1 1],...
                        'DrawMode','fast',...
                        'Visible','on',...
                        'OuterPosition',aop,...
                        'Position',ap,...
                        'Parent', obj.ui.Figure);
            end
           
            nFrames = 100;
            obj.ui.Slider = uicontrol('Style','slider',...
                'Parent',obj.ui.Panel,...
                'Max',nFrames,...
                'Min',1,...
                'Value',1,...
                'Units','normalized',...
                'Position',[.91 0 .08 1],...
                'SliderStep',[1/(nFrames-1) (0.1*nFrames)/(nFrames-1)],...
                'Callback',@(src,event)slider_cb(obj));
            
            % This does not work unfortunately.
            %jScrollBar = findjobj(obj.ui.Slider);
            %jScrollBar.AdjustmentValueChangedCallback = {@slider_cb,obj};
            
            editPos = 0;
            
            obj.ui.text = containers.Map();
            obj.AddEditText('Frame','1',0);
            obj.AddEditText('StartPos','81',1);
            
            % Build a menu of the data sets and populate it with
            % a list of all of the data set names.

            mnu = uimenu('Label','Data Sets');
            dsNames = sortrows(fieldnames(obj.dataSets));
            for k = 1:length(dsNames)
                uimenu(mnu,'Label',dsNames{k},...
                    'Callback',@(src,event)dataMenu_cb(obj,dsNames{k})...
                    );
            end
            
            mnu2 = uimenu('Label','Positions');
            acc = {'1','2','3','4','5','6'};
            for k = 1:length(obj.positions)
                uimenu(mnu2,'Label',obj.positions{k},...
                    'Callback',@(src,event)positionMenu_cb(obj,k),...
                    'Accelerator',acc{k});
            end
                
            obj.axesDisplay = 'Both';

            set(obj.ui.Figure,'Name','Gyro Glove Data Visualizer');
            
            set(obj.ui.Figure,'WindowScrollWheelFcn',@(src,event)mouseWheel_cb(obj,src,event));

            % Make the GUI visible.
            set(obj.ui.Figure,'Visible','on');
            obj.UpdateImages();
            obj.PlotData();
            obj.SetupSimData();
            drawnow;
        end
        
        function [h,u] = AddButtonGroup(obj,type,group,names,row)
            % A routine to make adding a set of butons easier.
            h = uibuttongroup('visible','on',...
                'Units','normalized',...
                'Position',[0.05 row*(0.1) 0.8 0.1],...
                'Parent',obj.ui.Panel);

            nitems = length(names);
            for x = 1:nitems
                n = names{x};
                
                u(x) = uicontrol('Style',type,...
                    'String',n,...
                    'Units','normalized',...
                    'pos',[(x-1)*(1/nitems) 0 1/nitems 1],...
                    'Parent',h,...
                    'HandleVisibility','off');
            end
            set(h,'SelectedObject',[]);
            set(h,'Visible','on');
        end
        
        function AddEditText(obj,label,value,row)
            % Add a text box and label.
            s.text = uicontrol('Style','text',...
                'Parent',obj.ui.Panel,...
                'String',label,...
                'Units','normalized',...
                'Position',[0.05 row*(0.1) 0.3 0.08]);
            
            s.edit = uicontrol('Style','edit',...
                'Parent',obj.ui.Panel,...
                'String',value,...
                'Units','normalized',...
                'Position',[0.41  row*(0.1) 0.5 0.08]);
            
            obj.ui.text(label) = s;
        end
        
        function  AddComboBox(obj,label,value,row)
            % Add a text box and label.
            s.text = uicontrol('Style','text',...
                'Parent',obj.ui.Panel,...
                'String',label,...
                'Units','normalized',...
                'Position',[0.05 row*(0.1) 0.3 0.08]);
            
            s.list = uicontrol('Style','listbox',...
                'Parent',obj.ui.Panel,...
                'String',value,...
                'Units','normalized',...
                'Position',[0.41  row*(0.1) 0.5 0.3]);
            
            obj.ui.list(label) = s;
        end
        
        function s = GetValue(obj,label)
            s = get(obj.ui.text(label).edit,'String');
        end
        
        function CalcAxesWidth(obj)
            % This depends on if we are displaying 1, 2, or 3 axes.
            % If 1, then that axes covers the entire width, 2 split half,
            % etc.
            switch obj.axesDisplay
                case 'Gyro'
                    obj.ui.axesWidth = 0.75/2-0.02;
                case 'Acc'
                    obj.ui.axesWidth = 0.75/2-0.02;
                case 'Both'
                    obj.ui.axesWidth = 0.75/3-0.02;
                case 'None'
                    obj.ui.axesWidth = 0.75;
            end
        end
        
        function SetAxes(obj,idx,n,hide)
            % idx is the index of which axes to display.. i.e. if we are
            % displaying 3 axes and this is the 2nd, then idx is 2.. we use
            % this as the offset of the first value, as calculated below.
            
            if hide
                % This moves the axes left of the displayed frame by a
                % frame size, effectively hiding it.
                aop = [-1 0 1 1];
                if n == 1
                    set(obj.ui.OutputAxes,...
                        'OuterPosition',aop,...
                        'Position',aop);
                elseif n == 2
                    for r = 1:3
                        set(obj.ui.GyroAxes(r),...
                            'OuterPosition',aop,...
                            'Position',aop);
                    end
                elseif n == 3
                    for r = 1:3
                        set(obj.ui.AccAxes(r),...
                            'OuterPosition',aop,...
                            'Position',aop);
                    end
                end
                    
            else
                if n == 1
                    aop = [0 0 obj.ui.videoWidth obj.ui.axesHeight];
                    set(obj.ui.OutputAxes,...
                        'OuterPosition',aop,...
                        'Position',aop);
                elseif n == 2
                    for r = 1:3
                        aop = [...
                            obj.ui.videoWidth+0.02 ...
                            (3-r)*obj.ui.dataHeight ...
                            obj.ui.dataWidth ...
                            obj.ui.dataHeight];
                        set(obj.ui.GyroAxes(r),...
                            'OuterPosition',aop,...
                            'Position',aop);
                    end
                elseif n == 3
                    for r = 1:3
                        aop = [...
                            obj.ui.videoWidth+obj.ui.dataWidth+0.04 ...
                            (3-r)*obj.ui.dataHeight ...
                            obj.ui.dataWidth ...
                            obj.ui.dataHeight];
                        set(obj.ui.AccAxes(r),...
                            'OuterPosition',aop,...
                            'Position',aop);
                    end
                end
            end
        end
        
        function UpdateAxesPos(obj)
            % I have some options I can use to allow for turning off some
            % of the axes.. If an axes is "off", I just move it out of the
            % window area.
            
            obj.CalcAxesWidth();

            % First axes.. always dislayed. 
            obj.SetAxes(1,1,false);

            % Set the 2nd and 3rd axes, depending on the display setting.
            switch obj.axesDisplay
                case {'Gyro'}
                    obj.SetAxes(2,2,false);
                    obj.SetAxes(3,3,true);
                case {'Acc'}
                    obj.SetAxes(2,2,true);
                    obj.SetAxes(2,3,false);
                case {'Both'}
                    obj.SetAxes(2,2,false);
                    obj.SetAxes(3,3,false);
                case {'None'}
                    obj.SetAxes(2,2,true);
                    obj.SetAxes(3,3,true);
            end
        end
        
        function PlotData(obj)
            % Collect some text box data, and then update the axes if they
            % are displayed.
            % The update calls the videoproc object to show the data. Note
            % that the "ShowCalc" function will show different types of
            % data, depending on the obj.dataFrame value.
            
            currData = obj.dataSets.(obj.currDataSet);
            if isfield(currData,'T')
                T = currData.T;
            else
                T = 1/180;
            end
            [rows,c] = size(currData.data)
            T_Stop = T*rows;

            idx = (obj.currDataIndex-1) * 7;
            switch obj.axesDisplay
                case {'Gyro','Both'}
                    for r = 1:3
                        axes = obj.ui.GyroAxes(r);
                        plot(axes,500*2*pi/360*(currData.data(:,idx+r+2)/(2^15-1)));
                        title(axes,'Gyro Data');
                        xlim(axes,[0 rows]);
                        ylim(axes,[-500*2*pi/360 500*2*pi/360]);
                    end
            end
            
            switch obj.axesDisplay
                case {'Acc','Both'}
                    for r = 1:3
                        axes = obj.ui.AccAxes(r);
                        plot(axes,2*currData.data(:,idx+r+5)/(2^15-1));
                        title(axes,'Accelerometer Data');
                        xlim(axes,[0 rows]);
                        ylim(axes,[-2 2]);
                    end
            end
            
            drawnow expose;
            
        end
        
        function SetupSimData(obj)
            global imudata
            global T_Stop;
            global T;
            currData = obj.dataSets.(obj.currDataSet);
            idx = (obj.currDataIndex-1) * 7;
            [r,c] = size(currData.data);
            imudata = zeros(r,7);
            imudata(:,2:7) = currData.data(:,idx+3:idx+8);
            if isfield(currData,'T')
                T = currData.T;
            else
                T = 1/180;
            end
            [r,c] = size(imudata);
            T_Stop = T*r;
            imudata(:,2:4) = 500*2*pi/360*(imudata(:,2:4)/(2^15-1));
            imudata(:,5:7) = 2*(imudata(:,5:7)/(2^15-1));
            imudata(:,1) = [0:T:(r-1)*T];
            %sim('IMUSim');
        end
        
        function UpdateImages(obj,curr_idx)
        end
        
        function DrawPosition(obj)
            pos = obj.curr_idx;
            s = obj.GetValue('StartPos');
            startPos = str2num(s);
            if pos > startPos
                apos = pos - startPos
                apos = apos * 3; % 3 IMU values per frame
                for r = 1:3
                    set(obj.ui.Figure,'CurrentAxes',obj.ui.GyroAxes(r));
                    line([apos apos],[-32768 32768],'Color','r');
                    set(obj.ui.Figure,'CurrentAxes',obj.ui.AccAxes(r));
                    line([apos apos],[-32768 32768],'Color','r');
                end
            end
        end
        
        % _cb routines are called by the gui at certain times, i.e. when
        % the text boxes change, or the slider changes, or mouse, etc. Do
        % the right action based on what gets called.
        
        function slider_cb(obj)
            curr_val = get(obj.ui.Slider,'Value');
            curr_idx = round(curr_val);
        end
        
        function mouseWheel_cb(obj,src,evnt)
            newVal = obj.curr_idx;
            if evnt.VerticalScrollCount > 0
                newVal = newVal - 1;
            elseif evnt.VerticalScrollCount < 0
                newVal = newVal + 1;
            end
            
            if newVal < 1
                newVal = 1;
            end
            obj.curr_idx = newVal;
        end
        
        function dataMenu_cb(obj,dataName)
            obj.currDataSet = dataName;
            obj.PlotData();
            obj.SetupSimData();
        end
        
        function positionMenu_cb(obj,posIndex)
            obj.currDataIndex = posIndex;
            obj.PlotData();
            obj.SetupSimData();
        end
        
    end
    
end


