function varargout = plot_window(varargin)
% PLOT_WINDOW MATLAB code for plot_window.fig
%      PLOT_WINDOW, by itself, creates a new PLOT_WINDOW or raises the existing
%      singleton*.
%
%      H = PLOT_WINDOW returns the handle to a new PLOT_WINDOW or the handle to
%      the existing singleton*.
%
%      PLOT_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_WINDOW.M with the given input arguments.
%
%      PLOT_WINDOW('Property','Value',...) creates a new PLOT_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot_window

% Last Modified by GUIDE v2.5 21-Jun-2018 03:40:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_window_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_window_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before plot_window is made visible.
function plot_window_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plot_window (see VARARGIN)

%plot_window(signal_all, sparam,labels,D,window,plot_cond, page, yl, bch)

handles.signal_all= varargin{1};
handles.sparam = varargin{2};
handles.labels = varargin{3};
handles.D = varargin{4} ;
handles.window = varargin{5};
handles.plot_cond = varargin{6} ;
handles.page = varargin{7};
handles.yl = varargin{8};
handles.bch = varargin{9};
handles.t = varargin{10};
handles.signal_org = [];
setappdata(hObject,'signal_org',varargin{11});
handles.bc_type = varargin{12};
handles.bc_win = 100:300;
handles.showslice = 0;
    handles.elecMatrix=[];
    handles.elecLabels=[];
    handles.elecRgb=[];
    handles.eleinuse = [];
    handles.V = [];
    handles.order = 1:nchannels(handles.D{1});
handles.output = hObject;
set(handles.slider1,'value',0.3);
set(handles.slider3,'enable','off');
set(handles.axes4,'visible','off');
set(handles.checkbox2,'visible','off');
if isempty(handles.signal_org)
    set(handles.slider2,'enable','off');
end
handles.sparam = (get(handles.slider1,'value'))*50;
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using plot_window.
% if strcmp(get(hObject,'Visible'),'off')
%    % plot(rand(5));
% end

set(gcf,'color',[1 1 1]);
handles.overlay=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[V,mgridfilenames,leptoCoor, surfpath] = get_images(handles.D{1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.V = V;
try
    [handles.elecMatrix, handles.elecLabels, handles.elecRgb]=mgrid2matlab(mgridfilenames);
    handles.elecMatrix=round(handles.elecMatrix);
    dd=diff(handles.elecRgb(:,1));
    dd=[0;dd];
    id=find(dd~=0);
    id2=[id-1;size( handles.elecRgb,1)];
    id1=[1;id];
    handles.group=[id1 id2];
catch
end
handles.elecoor = leptoCoor;
%% rearrange the channel labels 
try
    if ~isempty(handles.elecLabels)
        for ii=1:length( handles.elecLabels)
            handles.m(ii,:)=strsplit(handles.elecLabels{ii},'_');
        end
        for ii=1:length(chanlabels(handles.D{1}))
            modi(ii)=string(erase(char(chanlabels(handles.D{1},ii)),["_","-",".","EEG"]));
        end
        order = cell(1, length(handles.elecLabels));
        handles.order = nan(1, length(handles.elecLabels));
        for ii=1:length( handles.elecLabels)
            order{ii}=find(strcmpi(strcat(handles.m(ii,2),handles.m(ii,3)),modi));
            if isempty(order{ii})
                if ii < length( handles.elecLabels) && ii > 1
                    if(find(strcmpi(strcat(handles.m(ii+1,2),handles.m(ii+1,3)),modi))-order{ii-1}==-2)
                        order{ii} = order{ii-1}-1;
                    elseif (find(strcmpi(strcat(handles.m(ii+1,2),handles.m(ii+1,3)),modi))-order{ii-1}==2)
                        order{ii} = order{ii-1}+1;
                    end
                else
                    order{ii} = nan;
                end
            elseif length(order{ii})>1
                order{ii} = order{ii}(end);
            end
            handles.order(ii) = order{ii};
        end
        misind=find(isnan(handles.order));
        if ~isempty(misind)
            eind=sort(handles.order);
            eind(isnan(eind))=[];
            check=1:(nchannels(handles.D{1}));
            check(eind)=[];
            fin = find(isnan(handles.order));
            compareind=handles.order([fin+1 fin-1]);
            for i=1:length(check)
                cname = lower(chanlabels(handles.D{1},check(i)));
                if any(abs(check(i)-compareind)==1) && ...
                        ~contains(cname,'ref') && ...
                        ~contains(cname,'ekg') && ...
                        ~contains(cname,'ecg') && ...
                        ~contains(cname,'edf')
                    found = find(abs(check(i)-compareind)==1);
                    if found > length(misind)
                        found = found -length(misind);
                    end
                    handles.order(misind(found))=check(i);
                end
            end
        end
    end
catch
    disp('Can not match the channel names with imaging data.')
end
%% Plot cortex model
if ~isempty(handles.elecoor) || ~isempty(handles.elecMatrix)
    axes(handles.axes3);
    if exist(fullfile(surfpath,'rh.pial'),'file') && ~isempty(handles.elecoor)
        
        handles = plot_mesh(handles, surfpath);
        set(handles.slider3,'enable','on');
        handles.eleinuse = handles.elecoor;
        
    elseif ~isempty(handles.V)
        set(handles.checkbox2,'visible','off','value',0);
        handles.showslice = 1;
        handles.eleinuse = handles.elecMatrix;
        plot_3dslice(handles);
    end
    %% add label
    handles.labeltext = text(handles.eleinuse(1,1),handles.eleinuse(1,2),handles.eleinuse(1,3),...
        string(strcat(handles.m(1,2),handles.m(1,3))),'FontSize',18);
    %% add marker
    handles.currele = plot3(handles.eleinuse(1,1),handles.eleinuse(1,2),handles.eleinuse(1,3),...
        'o','markersize',12,'linewidth',3);
    rotate3d(handles.axes3,'on');
    axis off
    axis(handles.axes3,'vis3d');
else
    set(handles.axes3,'visible','off');
    set(handles.axes1,'position',[0.2 0.08 0.75 0.8],'units','normalized');
end
set(gca,'color',[1 1 1]);

%% plot slice
plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)

%% plot signal
axes(handles.axes1);
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)

set(handles.listbox1,'string',chanlabels(handles.D{1},handles.order(~isnan(handles.order))));
set(handles.popupmenu1,'string',{'Zscore' 'Log'});
switch handles.bc_type
    case 'z'
        set(handles.popupmenu1,'value',1);
    case 'log'
        set(handles.popupmenu1,'value',2);
end

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = plot_window_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page < length(handles.order)
    handles.page=handles.page+1;

plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
if ~isempty(handles.eleinuse)
    set(handles.labeltext,'position',...
        [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
        'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
    set(handles.currele,'xdata',...
        handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
end
axes(handles.axes1);
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bc_type = get(hObject,'value');
bc_old = handles.bc_type;
switch bc_type
    case 1
        handles.bc_type = 'z';
    case 2
        handles.bc_type = 'log';
end
if strcmp(bc_type,bc_old)
    return;
end
signal_org = getappdata(gcf, 'signal_org');
if isempty(signal_org)
    return;
end

for i = 1:length(handles.signal_org)
    signalbc{i} = baseline_norm(handles.signal_org{i}, handles.window, handles.bc_win, handles.bc_type);
end
handles = arrange(signalbc, handles);
axes(handles.axes1);
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white','string',{'zscore' 'log'});
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page > 1
    handles.page=handles.page-1;

plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
if ~isempty(handles.eleinuse)
    set(handles.labeltext,'position',...
        [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
        'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
    set(handles.currele,'xdata',...
        handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
end
axes(handles.axes1);
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
end
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sv = get(hObject,'Value')+0.02;
handles.sparam = sv*50;
axes(handles.axes1);
cla;
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for k=1:length(handles.signal_all)
    nanid = find(isnan(handles.signal_all{k}));
    nanid = [nanid nanid+5];
    nanid = [nanid nanid-5];
    handles.nanid = unique(sort(nanid));
    handles.signal_all{k}(handles.nanid)=nan;
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha=get(hObject,'Value');

    set(handles.lh,'facealpha',handles.alpha);
    set(handles.rh,'facealpha',handles.alpha);

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selchan = get(hObject,'Value');
handles.page = selchan;
plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
if ~isempty(handles.eleinuse)
    set(handles.labeltext,'position',...
        [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
        'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
    set(handles.currele,'xdata',...
        handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
end

axes(handles.axes1);
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    set(hObject,'string',chanlabels(handles.D{1},handles.order));
end

% --- Executes on key press with focus on figure1 or any of its controls.
% function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
% %	Key: name of the key that was pressed, in lower case
% %	Character: character interpretation of the key(s) that was pressed
% %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% % handles    structure with handles and user data (see GUIDATA)
% key=eventdata{1}.Key;
% switch key
%     case 'leftarrow'
%         pushbutton2_Callback(hObject, eventdata, handles);
%     case 'rightarrow'
%         pushbutton1_Callback(hObject, eventdata, handles);
%     case 'uparrow'
%         handles.yl(2) = handles.yl(2)+0.5;
%         handles.yl(1) = handles.yl(1)-0.3;
%         axes(handles.axes1);
%         plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
%     handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
%         
%     case 'downarrow'
%         handles.yl(2) = handles.yl(2)-0.5;
%         handles.yl(1) = handles.yl(1)*0.8;
%         axes(handles.axes1);
%         plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
%     handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
% end
% guidata(hObject, handles);


% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
% hObject    handle to savebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 resultdname = fullfile(path(handles.D{1}),'New figures');
        if ~exist(resultdname,'dir')
            mkdir(resultdname);
        end
       
figure;
set(gcf,'Position',[500 600 800 600]);
set(gcf,'color',[1 1 1]);  
disp('-------------Saving all figures--------------')
for i = 1:length(handles.order)
    name=char(chanlabels(handles.D{1},i));
    progress(i,length(handles.order),80,0)
    plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(i), handles.yl,handles.bch,handles.t)
print('-opengl','-r300','-dpng',fullfile(resultdname,name));

end
 

% --- Executes on button press in export.
function export_Callback(hObject, ~, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin ('base','Signal',handles.signal_all);
disp('-------------Data exported to workspace--------------')
guidata(hObject, handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.showslice = get(hObject,'Value');
if handles.showslice
    set(handles.axes4,'visible','on');
    set(handles.axes3,'visible','off');
    set(handles.s,'visible','on');
    handles.elecinuse = handles.elecMatrix;
else
    set(handles.axes4,'visible','off');
    set(handles.axes3,'visible','on');
    handles.elecinuse = handles.elecoor;
end
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.yl(2) = handles.yl(2)*1.1;
        handles.yl(1) = handles.yl(1)*1.1;
        axes(handles.axes1);
        ylim(handles.yl);
%         plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
%     handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
guidata(hObject, handles);
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        handles.yl(2) = handles.yl(2)*0.9;
        handles.yl(1) = handles.yl(1)*0.9;
        axes(handles.axes1);
        ylim(handles.yl);
%         axes(handles.axes1);
%         plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
%     handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
guidata(hObject, handles);
