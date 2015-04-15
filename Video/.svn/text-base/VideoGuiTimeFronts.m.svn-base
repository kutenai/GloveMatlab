classdef VideoGuiTimeFronts < VideoGui
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = VideoGuiTimeFronts(vp)
            obj = obj@VideoGui(vp);
        end
        
        function InitGui(obj)
            
            figWidth = 1200;
            figHeight = 580;
            obj.ui = struct();
            obj.ui.Figure = figure(...
                'Visible','Off',...
                'Colormap',gray(256),...
                'Position',[100 100 figWidth figHeight]);
            
            obj.ui.Panel = uipanel('Title','Controls','FontSize',12,...
                'Parent',obj.ui.Figure,...
                'Units','normalized',...
                'Position',[0.75 0 0.25 1]);
                
            
            obj.ui.axesWidth = 0.75/3-0.02;
            obj.ui.axesHeight = 1;
            
            for x = 1:2
                aop = [(x-1)*(obj.ui.axesWidth+0.02) 0 obj.ui.axesWidth obj.ui.axesHeight];
                ap = aop;
                obj.ui.Axes(x) = axes(...
                    'DataAspectRatio', [1 1 1],...
                    'DrawMode','fast',...
                    'Visible','off',...
                    'OuterPosition',aop,...
                    'Position',ap,...
                    'Parent', obj.ui.Figure);
            end
           
            nFrames = obj.vp.FrameCount();
            obj.ui.Slider = uicontrol('Style','slider',...
                'Parent',obj.ui.Panel,...
                'Max',nFrames,...
                'Min',1,...
                'Value',1,...
                'Units','normalized',...
                'Position',[.91 0 .08 1],...
                'SliderStep',[1/(nFrames-1) (0.1*nFrames)/(nFrames-1)],...
                'Callback',@(src,event)slider_cb(obj));
            
            
            editPos = 0;
            
            obj.ui.text = containers.Map();
            obj.AddEditText('Frame','1',0);
            obj.AddEditText('Dr','1',1);
            obj.AddEditText('Dc','1',2);

            calcFmts = obj.vp.CalcFormats();
            [h2,u2] = obj.AddButtonGroup('Radio','Display',calcFmts,6);
            set(h2,'SelectionChangeFcn',@(src,event)buttons_display_cb(obj,src,event));
            set(h2,'SelectedObject',[u2(1)]);
            obj.dataFrame = calcFmts{1};

            [h3,u3] = obj.AddButtonGroup('Toggle','Display',{'Original' 'Calc' 'Both'},7);
            set(h3,'SelectionChangeFcn',@(src,event)buttons_axes_cb(obj,src,event));
            set(h3,'SelectedObject',[u2(1)]);
            obj.axesDisplay = 'Both';

            set(obj.ui.Figure,'Name','Video Motion Visualization Tool');
            
            set(obj.ui.Figure,'WindowScrollWheelFcn',@(src,event)mouseWheel_cb(obj,src,event));

            obj.UpdateAxesPos();
            obj.UpdateImages(1);

            % Make the GUI visible.
            set(obj.ui.Figure,'Visible','on');
            drawnow;
        end
        
        function SetFrameNum(obj,n)
            % As the frame number changes, update an object parameter, and
            % set the text boxes. Also, get the new position data.
            % The position data is sort of specific to the "registered"
            % frames.. so, this makes the GUI a bit less generic.
            
            set(obj.ui.text('Frame').edit,'String',sprintf('%d',n));
            posData = obj.vp.PosData();
            if length(posData) > n
                set(obj.ui.text('Dr').edit,'String',sprintf('%d',posData(n,1)));
                set(obj.ui.text('Dc').edit,'String',sprintf('%d',posData(n,2)));
            else
                set(obj.ui.text('Dr').edit,'String','');
                set(obj.ui.text('Dc').edit,'String','');
            end
        end
        
        function w = CalcAxesWidth(obj)
            % This depends on if we are displaying 1, 2, or 3 axes.
            % If 1, then that axes covers the entire width, 2 split half,
            % etc.
            
            w = 0.75;
            switch obj.axesDisplay
                case {'Both'}
                    w = 0.75/2-0.02;
            end
            obj.ui.axesWidth = w;
        end
        
        function SetAxes(obj,idx,n,hide)
            % idx is the index of which axes to display.. i.e. if we are
            % displaying 3 axes and this is the 2nd, then idx is 2.. we use
            % this as the offset of the first value, as calculated below.
            
            if hide
                % This moves the axes left of the displayed frame by a
                % frame size, effectively hiding it.
                aop = [-1 0 1 1];
                set(obj.ui.Axes(n),...
                    'OuterPosition',aop,...
                    'Position',aop);
            else
                lPos = (idx-1)*(obj.ui.axesWidth+0.02);
                aop = [lPos 0 obj.ui.axesWidth obj.ui.axesHeight];
                set(obj.ui.Axes(n),...
                    'OuterPosition',aop,...
                    'Position',aop);
            end
        end
        
        function UpdateAxesPos(obj)
            % I have some options I can use to allow for turning off some
            % of the axes.. If an axes is "off", I just move it out of the
            % window area.
            
            obj.CalcAxesWidth();

            % Set the second axis if is on or both are on.
            switch obj.axesDisplay
                case {'Original'}
                    % Hide 2nd axes
                    obj.SetAxes(1,1,false);
                    obj.SetAxes(2,2,true);
                case {'Calc'}
                    % Hide first axes
                    obj.SetAxes(1,1,true);
                    obj.SetAxes(1,2,false); % hide second axes
                case {'Both'}
                    % Show both

                    obj.SetAxes(1,1,false);
                    obj.SetAxes(2,2,false);
            end
        end
        
        function UpdateImages(obj,curr_idx)
            
            switch obj.axesDisplay
                case {'Original'}
                    obj.vp.Show(obj.ui.Axes(1),curr_idx);
                case {'Calc'}
                    obj.vp.ShowCalc(obj.ui.Axes(2),curr_idx,obj.dataFrame);
                case {'Both'}
                    obj.vp.Show(obj.ui.Axes(1),curr_idx);
                    obj.vp.ShowCalc(obj.ui.Axes(2),curr_idx,obj.dataFrame);
            end
            
            for x=1:2
                set(obj.ui.Axes(x),'Visible','off');
            end
            
            obj.curr_idx = curr_idx;
            drawnow;
        end
        

    end
    
end


