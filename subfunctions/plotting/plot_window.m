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
%LBCN_viewer_getDefault
try
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
    setappdata(hObject,'signal_other',varargin{11});
    handles.bc_type = varargin{12};
catch
    script_view_results; % In case nothing is sent in
end
handles.signal_backup=handles.signal_all;
if length(varargin) == 13
    handles.nanid = varargin{13};
else
nanid = cell(size(handles.signal_all));
for k=1:length(handles.plot_cond)
    for j = 1:length(handles.signal_all{k})
        nanid{k}{j} = (isnan(handles.signal_all{k}{j}));
    end
end
handles.nanid = nanid;
end
handles.showslice = 0;
    handles.elecMatrix=[];
    handles.elecLabels=[];
    handles.elecRgb=[];
    handles.eleinuse = [];
    handles.V = [];
    handles.m = {};
    handles.order = 1:nchannels(handles.D{1});
handles.sel_cond = true(length(handles.plot_cond),1)';
handles.output = hObject;
set(handles.slider1,'value',0.3);
set(handles.slider3,'enable','off');
set(handles.axes4,'visible','off');
set(handles.checkbox2,'visible','off');
% if isempty(handles.atf)
%     set(handles.slider2,'enable','off');
% end
handles.sparam = (get(handles.slider1,'value'))*60;
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
V=V./max(V(:));
try
    V=smooth3(V,'gaussian',3);
catch
end
handles.V = V;
try
    [handles.elecMatrix, handles.elecLabels, handles.elecRgb]=mgrid2matlab(mgridfilenames);
    handles.elecMatrix=round(handles.elecMatrix);
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
            mc = char(chanlabels(handles.D{1},ii));
            modi(ii)=string(erase(mc,["EEG","_","-","."," "]));
        end
        if size(handles.m,2) ~=3
            side = cell(size(handles.m,1),1);
            handles.m = [side  handles.m];
        end
        order = cell(1, length(handles.elecLabels));
        handles.order = nan(1, length(handles.elecLabels));
        for ii=1:length( handles.elecLabels)
            order{ii}=find(strcmpi(strcat(handles.m(ii,2),handles.m(ii,3)),modi));
            if isempty(order{ii})
                if ii < length( handles.elecLabels) && ii > 1
                    next = find(strcmpi(strcat(handles.m(ii+1,2),handles.m(ii+1,3)),modi));
                    if ~isempty(next) && next-order{ii-1}==-2
                        order{ii} = order{ii-1}-1;
                    elseif ~isempty(next) && next-order{ii-1}==2
                        order{ii} = order{ii-1}+1;
                    else
                        order{ii} = nan;
                    end
                else
                    order{ii} = nan;
                end
            elseif length(order{ii})>1
                order{ii} = order{ii}(end);
                handles.m(ii,2)=strcat(handles.m(ii,2),'_',handles.m(ii,1));
                
            end
            handles.order(ii) = order{ii};
        end
        misind=find(isnan(handles.order));
        if ~isempty(misind)
            eind=sort(handles.order);
            eind(isnan(eind))=[];
            check=1:(nchannels(handles.D{1}));
            check(eind)=[];%labels in edf that do not match the image data
            fin = find(isnan(handles.order));
            compareind=handles.order([fin+1 fin-1]);%Neighbors of labels in the image data that did not find a match
            for i=1:length(check)
                cname = lower(modi(check(i)));%channel label in edf file
                if any(abs(check(i)-compareind)==1) && ... % For those mismatched labels, first look for neiboring labels
                        ~contains(cname,'ref') && ...
                        ~contains(cname,'ekg') && ...
                        ~contains(cname,'ecg') && ...
                        ~contains(cname,'edf')
                    found = find(abs(check(i)-compareind)==1);
                    if found > length(misind)
                        found = found -length(misind);
                    end
                    handles.order(misind(found))=check(i);
                elseif length(find(diff(diff(misind))==0)) == length(find(diff(diff(check))==0)) && ~isempty(find(diff(diff(misind))==0, 1))
                    fc = find(diff(diff(check))==0);
                    handles.order(misind)=sort(check(fc(1):(fc(end)+2)),'descend'); % If the mislabeled chan = missing chan
                    break;
                end
            end
        end
        if any(isnan(handles.order))%if there is still mismatched label
            misind2=find(isnan(handles.order));
            for k = misind2
                index = find_most_similar(strcat(handles.m{k,2},handles.m{k,3}), modi(check));
                index = index(end);
                handles.order(k)=check(index);
                %cn = char(modi(check(index)));
                cn = char(chanlabels(handles.D{1},check(index)));
                handles.m{k,2} = cn(isstrprop(cn,'alpha'));
                check(index) = [];
            end
        end
    end
catch
    disp('Can not match the channel names with imaging data.')
end

%% Get group names, add some color if needed
if length(unique(sum(handles.elecRgb,2))) == 1
    handles.elecRgb = map_color(handles.m(:,2));
end
if ~isempty(handles.elecRgb)
    dd=diff(handles.elecRgb(:,1));
    dd=[0;dd];
    id=find(dd~=0);
    id2=[id-1;size( handles.elecRgb,1)];
    id1=[1;id];
    handles.group=[id1 id2];
    handles.groupNames = handles.m(id1,2);
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
        xyz=zeros(size(handles.elecMatrix));
        [~,~,d3] = size(handles.V);
        xyz(:,1)=handles.elecMatrix(:,2);
        xyz(:,2)=handles.elecMatrix(:,1);
        xyz(:,3)=d3-handles.elecMatrix(:,3);
        handles.eleinuse = xyz;
        slice = plot_3dslice(handles);
        handles.slice = slice;
    end
    %% add label
    handles.labeltext = text(handles.eleinuse(1,1),handles.eleinuse(1,2),handles.eleinuse(1,3),...
        strcat(handles.m(1,2),handles.m(1,3)),'FontSize',18);
    if handles.showslice
        set(handles.labeltext,'color',[1 1 1]);
    end
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


%% plot signal
axes(handles.axes1);
handles.legendp = plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t);

set(handles.listbox1,'string',chanlabels(handles.D{1},handles.order(~isnan(handles.order))));
set(handles.popupmenu1,'string',{'Zscore' 'Log'});
switch handles.bc_type
    case 'z'
        set(handles.popupmenu1,'value',1);
    case 'log'
        set(handles.popupmenu1,'value',2);
end

%% Add checkboxes to for condition selection
fsize = get(gcf,'position');
fl = fsize(3); fw = fsize(4);
for k=length(handles.plot_cond):-1:1
    handles.cbh(k) = uicontrol('Style','checkbox','String',handles.labels{handles.plot_cond(k)}, ...
                        'fontsize',12,...
                       'Value',1,'Position',...
                       round([fl*(handles.legendp(1)+handles.legendp(3)+0.01) ...
                       fw*(handles.legendp(2)+(handles.legendp(4)/length(handles.plot_cond))*(length(handles.plot_cond)-k))  ...
                       fw*((handles.legendp(3))*0.8)  ...
                       fw*((handles.legendp(4)*0.8/length(handles.plot_cond)))]),'Unit','normalized',...
                       'backgroundcolor',[1 1 1],...
                       'Callback',{@checkBoxCallback,k, handles});
end

%% plot 2D slice. Store the axes and electrode handles
handles.slice2d_axes = plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page);

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
    
    %plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
    if handles.showslice
        move_slice(handles);
    elseif ~isempty(handles.m) && ~strcmp(handles.m(handles.page,1),handles.m(handles.page-1,1))
            axes(handles.axes3);
            view(handles.eleinuse(handles.page,:));
            set(handles.light,'position',handles.eleinuse(handles.page,:));   
    end
    if ~isempty(handles.eleinuse)
        set(handles.labeltext,'position',...
            [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
            'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
        set(handles.currele,'xdata',...
            handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
    end
    axes(handles.axes1);
    plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
        handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
    
    move_2dslice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
end
set(handles.listbox1,'value',handles.page);
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
signal_other = getappdata(gcf, 'signal_other');
if isempty(signal_other{1})
    try
        signal_other = evalin('base', 'Signal2');
        signal_other = arrange(signal_other, handles);
    catch
        switch bc_old
            case 'z'
                bcv = 1;
            case 'log'
                bcv = 2;
        end
        set(hObject, 'value',bcv);
    	return;
    end
end
setappdata(gcf,'signal_other',handles.signal_backup);
handles.signal_all = signal_other;
handles.signal_backup = signal_other;
axes(handles.axes1);
plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
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

set(hObject, 'String', {'Zscore', 'Log'});


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page > 1
    handles.page=handles.page-1;
    
    %plot_slice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
    if handles.showslice
        move_slice(handles);
    elseif ~isempty(handles.m) && ~strcmp(handles.m(handles.page,1),handles.m(handles.page+1,1))
            axes(handles.axes3);
            view(handles.eleinuse(handles.page,:));
            set(handles.light,'position',handles.eleinuse(handles.page,:));  
    end
    if ~isempty(handles.eleinuse)
        set(handles.labeltext,'position',...
            [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)],...
            'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
        set(handles.currele,'xdata',...
            handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
    end
    move_2dslice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
    
    axes(handles.axes1);
    plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
        handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
    
end

set(handles.listbox1,'value',handles.page);
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sv = get(hObject,'Value')+0.02;
handles.sparam = sv*60;
axes(handles.axes1);
cla;
plot_browser(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
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
param = get(hObject,'Value')*100;
handles.signal_all=handles.signal_backup;
se = strel('line',param*100,90);
for k=1:length(handles.plot_cond)
    for j = 1:length(handles.signal_all{k})
        progress(j,length(handles.signal_all{k})*length(handles.plot_cond),80,0)
        nanid = handles.nanid{k}{j};
        results=imdilate(nanid,se);
        try
            handles.signal_all{k}{j}(results)=nan;
        catch
            handles.signal_all{k}{j}(:,end+1) = nan;
        end
        handles.signal_all{k}{j} = fillmissing(handles.signal_all{k}{j},'movmean',param*5);
    end
end
disp('.');
disp('-----------Done------------');
axes(handles.axes1);
plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
guidata(hObject, handles);
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

if handles.showslice
     move_slice(handles);
end
if ~isempty(handles.eleinuse)
    set(handles.labeltext,'position',...
        [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
        'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
    set(handles.currele,'xdata',...
        handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
end

axes(handles.axes1);
plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
move_2dslice(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
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
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
key=eventdata.Key;
switch key
    case 'leftarrow'
        pushbutton2_Callback(hObject, eventdata, handles);
    case 'rightarrow'
        pushbutton1_Callback(hObject, eventdata, handles);
    case 'uparrow'
        pushbutton9_Callback(hObject, eventdata, handles)
    case 'downarrow'
        pushbutton10_Callback(hObject, eventdata, handles)
end
guidata(hObject, handles);


% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
% hObject    handle to savebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 resultdname = fullfile(path(handles.D{1}),'New figures');
        if ~exist(resultdname,'dir')
            mkdir(resultdname);
        end
       
f = figure;
set(f,'Position',[500 600 800 600]);
set(f,'color',[1 1 1]);  
disp('-------------Saving all figures--------------')
for i = 1:length(handles.order)
    chanid = handles.order(i);
    name=char(chanlabels(handles.D{1},handles.order(i)));
    filename = strcat('Chan',num2str(chanid),'_',name);
    progress(i,length(handles.order),80,0)
    plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(i), handles.yl,handles.bch,handles.t,1);
print(f, fullfile(resultdname,filename),'-opengl','-r300','-dpng');

end
 

% --- Executes on button press in export.
function export_Callback(hObject, ~, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin ('base','hfb',handles.signal_all);
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
    xyz=zeros(size(handles.elecMatrix));
    [~,~,d3] = size(handles.V);
        xyz(:,1)=handles.elecMatrix(:,2);
        xyz(:,2)=handles.elecMatrix(:,1);
        xyz(:,3)=d3-handles.elecMatrix(:,3);
        handles.eleinuse = xyz;
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

function checkBoxCallback(hObject,eventdata,checkBoxId,handles)
hObject_b = hObject;
handles = guidata(gcf);
    handles.sel_cond(checkBoxId) = get(hObject_b,'Value');
    axes(handles.axes1);
plot_browser(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t);
guidata(hObject, handles);
