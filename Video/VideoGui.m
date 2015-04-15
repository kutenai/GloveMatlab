classdef VideoGui < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        vp                  = [];
        ui                  = [];
        
        currPlayIndex
        currPlayCount
        myTimer
        curr_idx
        dataFrame
        axesDisplay
                
    end
    
    methods
        function obj = VideoGui(vp)
            % Constructor. Takes as an argument the
            % video processing object which contains the images and such.
            obj.vp = vp;
            obj.ui = [];
            obj.InitGui();
        end
        
        function delete(obj)
            % This does not do much.. I was thinking I would add some stuf
            % here.
            display('Deleting the object.');
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
            
            for x = 1:3
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
            obj.AddEditText('Theta','30',1);
            obj.AddEditText('Lambda','30',2);
            
            %obj.AddButton('Play',3);
            
            [h,u1] = obj.AddButtonGroup('Radio','Smooth',{'None' '9x9' '3x3'},5);
            set(h,'SelectionChangeFcn',@(src,event)buttons_smooth_cb(obj,src,event));
            set(h,'SelectedObject',[u1(1)]);
            
            calcFmts = obj.vp.CalcFormats();
            [h2,u2] = obj.AddButtonGroup('Radio','Display',calcFmts,6);
            set(h2,'SelectionChangeFcn',@(src,event)buttons_display_cb(obj,src,event));
            set(h2,'SelectedObject',[u2(1)]);
            obj.dataFrame = 'Pk';

            [h3,u3] = obj.AddButtonGroup('Toggle','Display',{'N+1' 'Calc' 'Both' 'None'},7);
            set(h3,'SelectionChangeFcn',@(src,event)buttons_axes_cb(obj,src,event));
            set(h3,'SelectedObject',[u2(1)]);
            obj.axesDisplay = 'Both';

            set(obj.ui.text('Theta').edit,'Callback',@(src,event)theta_cb(obj));
            set(obj.ui.text('Lambda').edit,'Callback',@(src,event)lambda_cb(obj));
            
            set(obj.ui.Figure,'Name','Video Motion Visualization Tool');
            
            set(obj.ui.Figure,'WindowScrollWheelFcn',@(src,event)mouseWheel_cb(obj,src,event));

            obj.UpdateAxesPos();
            obj.UpdateImages(1);
            
            % Make the GUI visible.
            set(obj.ui.Figure,'Visible','on');
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
        
        function SaveFrames(obj,fmList,extList,fName)
            for x = 1:length(fmList)
                ext = extList{x};
                filenm = sprintf('%s_%s.jpg',fName,ext);
                f = getframe(obj.ui.Axes(fmList(x)));
                imwrite(f.cdata,filenm);
            end
        end
        
        function s = GetValue(obj,label)
            s = get(obj.ui.text(label).edit,'String');
        end
        
        function CalcAxesWidth(obj)
            % This depends on if we are displaying 1, 2, or 3 axes.
            % If 1, then that axes covers the entire width, 2 split half,
            % etc.
            switch obj.axesDisplay
                case 'N+1'
                    obj.ui.axesWidth = 0.75/2-0.02;
                case 'Calc'
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

            % First axes.. always dislayed. 
            obj.SetAxes(1,1,false);

            % Set the 2nd and 3rd axes, depending on the display setting.
            switch obj.axesDisplay
                case {'N+1'}
                    obj.SetAxes(2,2,false);
                    obj.SetAxes(3,3,true);
                case {'Calc'}
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
        
        function UpdateImages(obj,curr_idx)
            % Collect some text box data, and then update the axes if they
            % are displayed.
            % The update calls the videoproc object to show the data. Note
            % that the "ShowCalc" function will show different types of
            % data, depending on the obj.dataFrame value.
            
            s = obj.GetValue('Theta');
            theta = str2num(s);
            s = obj.GetValue('Lambda');
            lambda = str2num(s);
            obj.vp.Show(obj.ui.Axes(1),curr_idx);

            switch obj.axesDisplay
                case {'N+1','Both'}
                    obj.vp.Show(obj.ui.Axes(2),curr_idx+1);
            end
            
            switch obj.axesDisplay
                case {'Calc','Both'}
                    % Allow us to select what gets displayed in the data frame.
                    obj.vp.ShowCalc(obj.ui.Axes(3),curr_idx,obj.dataFrame,theta,lambda);
            end
            
            for x=1:3
                set(obj.ui.Axes(x),'Visible','off');
            end
            obj.curr_idx = curr_idx;
            drawnow;
        end
        
        function SetFrameNum(obj,n)
            % As the frame number changes, update an object parameter, and
            % set the text boxes. Also, get the new position data.
            % The position data is sort of specific to the "registered"
            % frames.. so, this makes the GUI a bit less generic.
            
            set(obj.ui.text('Frame').edit,'String',sprintf('%d',n));
        end
        
        % _cb routines are called by the gui at certain times, i.e. when
        % the text boxes change, or the slider changes, or mouse, etc. Do
        % the right action based on what gets called.
        
        function theta_cb(obj)
            obj.UpdateImages(obj.curr_idx);
        end
        
        function lambda_cb(obj)
            obj.UpdateImages(obj.curr_idx);
        end
        
        function slider_cb(obj)
            curr_val = get(obj.ui.Slider,'Value');
            curr_idx = round(curr_val);
            %display(sprintf('Current Val:%f Curr Index:%d\n',curr_val,curr_idx));
            obj.SetFrameNum(curr_idx);
            obj.UpdateImages(curr_idx);
            drawnow;
        end
        
        function buttons_smooth_cb(obj,src,event)
            s = get(get(src,'SelectedObject'),'String');
            obj.vp.SetPkSmooth(s);
            obj.UpdateImages(obj.curr_idx);
        end
        
        function buttons_display_cb(obj,src,event)
            s = get(get(src,'SelectedObject'),'String');
            obj.dataFrame = s;
            obj.UpdateImages(obj.curr_idx);
        end
        

        function buttons_axes_cb(obj,src,event)
            s = get(get(src,'SelectedObject'),'String');
            obj.axesDisplay = s;
            obj.UpdateAxesPos();
            obj.UpdateImages(obj.curr_idx);
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
            if newVal > obj.vp.FrameCount()
                newVal = obj.vp.FrameCount();
            end
            
            % this will trigger the rest of the changes..
            obj.SetFrameNum(newVal);
            obj.curr_idx = newVal;
            set(obj.ui.Slider,'Value',newVal);
            obj.UpdateImages(newVal);
        end
        
        
        % These last are some older functions but they still work. I was
        % thinking of adding buttons for them.

        function PlayFor(obj,nTimes)
            % Play through the sequence repeatedly - nTimes. No pause, play
            % as fast as it will. Not that fast really.
            for t = 1:nTimes
                for x = 1:obj.vp.FrameCount()
                    obj.SetFrameNum(x);
                    obj.UpdateImages(x);
                end
            end
        end
        
        function PlayTimed(obj,nTimes,period)
            % Play through the sequence with a timer. This one is cool. I
            % setup a callback timer, see the Play_cb function, that is
            % called once each period.. This gives a "frame rate". A normal
            % period is probably 1/30, or technically, 1/29.7 or so.
            
            obj.currPlayIndex = 1;
            obj.currPlayCount = nTimes;
            obj.myTimer = timer('TimerFcn',@(src,event)Play_cb(obj,src,event),'Period',period,'ExecutionMode','fixedRate');
            start(obj.myTimer);
        end
        
        function Play_cb(obj,src,event)
            % Callback for timer.. called after each period,.
            % This deletes the timer when it is done.
            
            obj.vp.Show(obj.ui.Axes(1),obj.currPlayIndex);
            drawnow;
            
            % Increment the index.. wrap at nFrames
            obj.currPlayIndex = obj.currPlayIndex + 1;
            if obj.currPlayIndex > obj.vp.FrameCount()
                obj.currPlayIndex = 1;
                obj.currPlayCount = obj.currPlayCount - 1;
                if obj.currPlayCount == 0
                    stop(obj.myTimer);
                    delete(obj.myTimer);
                end
            end
        end
        
    end
    
end


