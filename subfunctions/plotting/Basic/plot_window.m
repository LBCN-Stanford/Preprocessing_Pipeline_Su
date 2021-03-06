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

% Last Modified by GUIDE v2.5 11-Oct-2018 14:58:49

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
    handles.cpath = varargin{8};
    handles.yl = [-0.5 1.8];
    handles.bch = varargin{9};
    handles.t = varargin{10};
    setappdata(hObject,'signal_other',varargin{11});
    handles.bc_type = varargin{12};
catch
    [filename,pathname] = uigetfile({'*.mat;*.edf','Raw data or saved data'},...
                'MultiSelect', 'on');
            fname = fullfile(pathname,filename);
            fnamec = cellstr(fname);
            
            if isempty(fnamec{1}) || isempty(filename)
                return;
            else
                [~,~,format]=fileparts(fnamec{1});
                if strcmpi(format,'.edf')
                    fname = string(fname)';
                    LBCN_preprocessing_new(fname);
                elseif strcmpi(format,'.mat')
                    try
                        view_results_b(fname);
                        return;
                    catch
                        LBCN_plot_HFB(fname);
                        return;
                    end
                else
                    disp('------- Wrong data format');
                    return;
                end
            end   
%     view_results; % In case nothing is sent in
%     return
end


%% load
try
    if length(varargin) == 14 && ~isempty(varargin{14})
        information = varargin{14};
        if isfield(information,'project_name')
            handles.task = information.project_name;
        end
        if isfield(information,'sbj_name')
            handles.sname = information.sbj_name;
        end
        if isfield(information,'tf')
            handles.tf = information.tf{1};
        end
    else
        [handles.task,handles.sname] = get_info(handles.cpath);
        out = timer_getinfo(handles.task,handles.sname);
        handles.task = out.task;
        handles.sname = out.sname;
        
    end
    if isempty(handles.task) || isempty(handles.sname)
        [handles.task,handles.sname] = get_info(handles.cpath);
        out = timer_getinfo(handles.task,handles.sname);
        handles.task = out.task;
        handles.sname = out.sname;
    end
catch
    [handles.task,handles.sname] = get_info(handles.cpath);
    out = timer_getinfo(handles.task,handles.sname);
    handles.task = out.task;
    handles.sname = out.sname;
end
handles.figure1.Name = strcat(handles.sname,' ',handles.task);





%% Run permutation test

%onset = find(handles.t==0);
%resampR = length(handles.signal_all{1}{1})/fsample(handles.D{1});%see if data length is approximately equal to 1s. 
%ending = round(800*resampR/1);
%start = round(180*resampR/1);
ending = length(handles.signal_all{1}{1})-50;
start = round(length(handles.signal_all{1}{1})/5);
sig_chan = cell(length(handles.plot_cond),1);
fprintf('-------- Running permutation test for condition 1');
for k=1:length(handles.plot_cond)
        if k>1
            for idisp = 1:ceil(log10(k)) % delete previous counter display
                fprintf('\b');
            end
        fprintf('%d',k);
        end
        
   sig_chan{handles.plot_cond(k)} = permutation_test(handles.signal_all{handles.plot_cond(k)},start);   
end
fprintf('-----------\n');
handles.sig_chan = sig_chan;

%% 

handles.signal_backup=handles.signal_all;
if length(varargin) == 13 && ~isempty(varargin{13})
    if length(varargin{13})==1
        handles.nanid = varargin{13}{1};
    else
        handles.nanid = varargin{13};
    end
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
try
set(handles.popupmenu1,'value',handles.bc_type);
catch
end
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

set(gcf,'color',[0.985 0.985 0.985]);
handles.overlay=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try %structured data with image info
    ptimage = brain3d(handles.D{1});
    handles.elecoor = ptimage.elect_native;
    handles.elecLabels = cellstr(ptimage.elect_names);
    handles.elecRgb = [0 0.4470 0.7410].*ones(size(handles.elecoor));
    handles.elecMatrix=round(ptimage.elect_MNI);
    V = ptimage.volume;
     V=V./max(V(:));
     V=smooth3(V,'gaussian',3);
     handles.V = V;
    surfpath = ptimage.cortex;
catch 
    [V,mgridfilenames,leptoCoor, surfpath] = get_images(handles.D{1});
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% rearrange the channel labels 
try
    if ~isempty(handles.elecLabels)
        if contains(handles.elecLabels{1},'_')
            for ii=1:length( handles.elecLabels)
                handles.m(ii,:)=strsplit(handles.elecLabels{ii},'_');
            end
        elseif contains(handles.elecLabels{1},' ')
            for ii=1:length( handles.elecLabels)
                sp=strsplit(handles.elecLabels{ii},' ');
                handles.m(ii,1)=strcat(sp(:,3),sp(:,2));
                handles.m(ii,2)=cellstr((join(regexp(string(sp(:,1)),'[A-Z]','Match','ignorecase'),'')));
                handles.m(ii,3)=cellstr((join(regexp(string(sp(:,1)),'[1-9]','Match'),'')));
            end
        else
            for ii=1:length( handles.elecLabels)
                eid(ii) = str2num((join(regexp(string(handles.elecLabels{ii}),'[1-9]','Match'),'')));
            end
            if max(eid)>=16
                etype='s';
            else
                etype='d';
            end
            for ii=1:length( handles.elecLabels)
                handles.m(ii,1) = cellstr(strcat(handles.elecLabels{ii}(1),etype));
                handles.m(ii,2) = cellstr((join(regexp(string(handles.elecLabels{ii}),'[A-Z]','Match','ignorecase'),'')));
                handles.m(ii,3) = cellstr((join(regexp(string(handles.elecLabels{ii}),'[1-9]','Match'),'')));
            end
        end
        lb = chanlabels(handles.D{1});
        random_check = randi(length(chanlabels(handles.D{1})),1,2);
        if ~isempty(str2num(lb{random_check(1)})) &&  ~isempty(str2num(lb{random_check(2)})) 
            mrilabel = unique(handles.m(:,2));
            [eeglabelnew,inv] = relabel_tdt(lb, mrilabel);
            for ii=1:length(eeglabelnew)
                mc = char(eeglabelnew{ii});
                modi(ii)=string(erase(mc,[string('EEG'),string('_'),string('-'),string('.'),string(' '),string('''')]));
            end
        else
            for ii=1:length(chanlabels(handles.D{1}))
                mc = char(chanlabels(handles.D{1},ii));
                modi(ii)=string(erase(mc,[string('EEG'),string('_'),string('-'),string('.'),string(' '),string('''')]));
            end
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
    disp('Can not match channel labels with imaging data.')
    handles.elecoor = [];
    handles.elecMatrix = [];
    handles.V = [];
end

%% Get group names, add color if needed
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
    if isstruct(surfpath) && ~isempty(handles.elecoor)
        handles = plot_mesh_b(handles, surfpath);
        set(handles.slider3,'enable','on');
        handles.eleinuse = handles.elecoor;
        
    elseif exist(fullfile(surfpath,'rh.pial'),'file') && ~isempty(handles.elecoor)
        
        handles = plot_mesh_b(handles, surfpath);
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
        slice = plot_3dslice_b(handles);
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
    set(handles.axes1,'position',[0.1 0.11 0.9 0.85],'units','normalized');
end
set(gca,'color',[1 1 1]);


%% plot signal and show significant channels with suffix
Nt = length(handles.plot_cond);
handles.cc = brewermap(Nt,'Set1');%linspecer(Nt);
%axes(handles.axes1);
handles.legendp = plot_browser_b(handles.signal_all, handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc,handles.axes1);

order = handles.order(~isnan(handles.order));
%clr = repmat( [0.7 0.7 0.7],nchannels(handles.D{1}),1);
% for j = 1:length(handles.plot_cond)
%     id = handles.sig_chan{j};
%     clr(id,:) = repmat(cc(j,:),length(id),1);%make significant channels the same color as the corresponding condition
% end
% sig_any=[];
% for jj = 1:length(handles.plot_cond)
%     sig_any = [sig_any;handles.sig_chan{jj}];
% end
% sig_any = unique(sig_any);
% sig_names = chanlabels(handles.D{1},sig_any);

for jj = 1:length(handles.plot_cond)
    sig_names{jj} = chanlabels(handles.D{1},handles.sig_chan{jj});
end
ppre = '<HTML>';
ppost = '</HTML>';
pre = '<FONT color="';
post = '</FONT>';
for j = 1:length(order)
    chanstr(j).name = chanlabels(handles.D{1},order(j));
    chanstr(j).Color = [179 179 179];
    suffix{j} = '';
    for jj = 1:length(handles.plot_cond)
        if any(strcmp(chanstr(j).name,sig_names{jj}))
            suffix{j} = strcat(suffix{j},pre, rgb2Hex( round(handles.cc(jj,:).*255) ), '">' ,'*' ,post);
        end
    end
end

listboxStr = cell(numel( chanstr ),1);
for i = 1:numel( chanstr )
   str = strcat(ppre, pre, rgb2Hex( chanstr(i).Color ), '">' ,chanstr(i).name ,post ,suffix{i},ppost);
   listboxStr(i) = str;
end
%set(handles.listbox1,'string',chanlabels(handles.D{1},handles.order(~isnan(handles.order))));
set(handles.listbox1,'string',listboxStr);
set(handles.popupmenu1,'string',{'Zscore' 'Log'});
switch handles.bc_type
    case 'z'
        set(handles.popupmenu1,'value',1);
    case 'log'
        set(handles.popupmenu1,'value',2);
end

%% Add checkboxes to for condition selection
p = findobj('tag','condpanel');
psize = get(p,'position');fsize = get(gcf,'position');psize = [psize(1)*fsize(1) psize(2)*fsize(2) psize(3)*fsize(3) psize(4)*fsize(4)];
fl = psize(3); fw = psize(4);
n = 1;
for k=length(handles.plot_cond):-1:1
    handles.cbh(k) = uicontrol('Style','checkbox','String',handles.labels{handles.plot_cond(k)}, ...
                        'fontname','optima','fontsize',15,...
                       'Value',1,'Position', ([0.2 ...
                       fw*(handles.legendp(2)/1.5+(1.5*handles.legendp(4)/length(handles.plot_cond))*(length(handles.plot_cond)-k))  ...
                       fw*((handles.legendp(3))*1.5)  ...
                       fw*((handles.legendp(4)*1.5/length(handles.plot_cond)))]),'Unit','normalized',...
                       'backgroundcolor',[0.98 0.98 0.98],...
                       'Callback',{@checkBoxCallback,k, handles},'parent',handles.condpanel);
%     handles.cbh(k) = uicontrol('Style','checkbox','String',handles.labels{handles.plot_cond(k)}, ...
%                         'fontname','optima','fontsize',12,...
%                        'Value',1,'Position', ([fl*(handles.legendp(1)+handles.legendp(3)+0.01) ...
%                        fw*(handles.legendp(2)+(handles.legendp(4)/length(handles.plot_cond))*(length(handles.plot_cond)-k))  ...
%                        fw*((handles.legendp(3))*0.8)  ...
%                        fw*((handles.legendp(4)*0.8/length(handles.plot_cond)))]),'Unit','normalized',...
%                        'backgroundcolor',[1 1 1],...
%                        'Callback',{@checkBoxCallback,k, handles});
end

%% plot 2D slice. Store the axes and electrode handles
handles.slice2d_axes = plot_slice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page);

handles.export.Enable = 'on';
handles.inspectBtn.Enable = 'on';
handles.savebtn.Enable = 'on';
handles.pushbutton2.Enable = 'on';
handles.pushbutton1.Enable = 'on';
handles.mripanel.Visible = 'on';
handles.popupmenu1.Enable = 'on';
handles.listbox1.Enable = 'on';

handles.Button.Visible = 'on';
%handles.openBtn.Enable = 'off';
%handles.loadBtn.Enable = 'off';
handles.axes1.Visible = 'on';
%handles.axes3.Visible = 'on';
handles.slider1.Enable = 'on';
handles.slider2.Enable = 'on';
handles.slider3.Enable = 'on';
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function plot_window_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page < length(handles.order)
    handles.page=handles.page+1;
    
    %plot_slice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
    if handles.showslice
        move_slice_b(handles);
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
    %axes(handles.axes1);
    plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
        handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), ...
        handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
    
    move_2dslice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
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
%axes(handles.axes1);
plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
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
    
    %plot_slice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page)
    if handles.showslice
        move_slice_b(handles);
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
    move_2dslice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
    
    %axes(handles.axes1);
    plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
        handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
    
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
plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
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
param = get(handles.slider2,'Value')*100;
            handles.signal_all=handles.signal_backup;
            se = strel('line',param*2,90);
            for k=1:length(handles.plot_cond)
                for j = 1:length(handles.signal_all{k})
                    nanidx = handles.nanid{k}{j};
                    results=logical(imdilate(nanidx,se));
                    try
                        handles.signal_all{k}{j}(results)=nan;
                    catch
                        handles.signal_all{k}{j}(:,end+1) = nan;
                    end
                    %app.signal_all{k}{j} = fillmissing(app.signal_all{k}{j},'movmean',param*10);
                end
            end
            %disp('-----------Done------------');
            %axes(app.axes1);
            plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
                handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
            guidata(hObject,handles);
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
     move_slice_b(handles);
end
if ~isempty(handles.eleinuse)
    set(handles.labeltext,'position',...
        [handles.eleinuse(handles.page,1) handles.eleinuse(handles.page,2) handles.eleinuse(handles.page,3)+2],...
        'string',string(strcat(handles.m(handles.page,2),handles.m(handles.page,3))));
    set(handles.currele,'xdata',...
        handles.eleinuse(handles.page,1),'ydata' ,handles.eleinuse(handles.page,2),'zdata' ,handles.eleinuse(handles.page,3));
end

%axes(handles.axes1);
plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
move_2dslice_b(handles.elecMatrix, handles.elecRgb, handles.V,handles.page, handles.slice2d_axes);
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
[task,sname] = get_info(path(handles.D{1}));

f = figure;
if ~isempty(handles.elecMatrix)
    set(f,'Position',[400 600 700 700]);
    %set(f,'Position',[400 600 700 500]);
    set(f,'color',[1 1 1]);
    disp('-------------Saving all figures--------------')
    ax1 = axes('Position',[0.1 0.45 0.85 0.5]);
    for i = 1:length(handles.order)
        chanid = handles.order(i);
        name=char(chanlabels(handles.D{1},handles.order(i)));
        filename = strcat(sname,name,'_',task);
        progress(i,length(handles.order),80,0)
        
        %axes(ax1);
        plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
            handles.window,handles.plot_cond(handles.sel_cond), handles.order(i), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),ax1);
        if i==1
            slice2d_axes = plot_slice_b(handles.elecMatrix, handles.elecRgb, handles.V,i);
        else
            move_2dslice_b(handles.elecMatrix, handles.elecRgb, handles.V,i, slice2d_axes);
        end
        %plot_slice_b(handles.elecMatrix, handles.elecRgb, handles.V,i);
        print(f, fullfile(resultdname,filename),'-opengl','-r300','-dpng');
        
    end
else
    set(f,'Position',[400 600 700 500]);
    set(f,'color',[1 1 1]);
    disp('-------------Saving all figures--------------')
    ax1 = axes('Position',[0.1 0.1 0.85 0.85]);
    for i = 1:length(handles.order)
        chanid = handles.order(i);
        name=char(chanlabels(handles.D{1},handles.order(i)));
        filename = strcat(sname,name,'_',task);
        progress(i,length(handles.order),80,0)
        
        %axes(ax1);
        plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
            handles.window,handles.plot_cond(handles.sel_cond), handles.order(i), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),ax1);
        print(f, fullfile(resultdname,filename),'-opengl','-r300','-dpng');
    end
end
% --- Executes on button press in export.
function export_Callback(hObject, ~, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% assignin ('base','hfb',handles.signal_all);
% disp('-------------Data exported to workspace--------------')
 f = figure;
            if ~isempty(handles.elecMatrix)
                set(f,'Position',[400 600 700 700]);
                %set(f,'Position',[400 600 700 500]);
                set(f,'color',[1 1 1]);
                %disp('-------------Saving all figures--------------')
                ax1 = axes('Position',[0.1 0.45 0.85 0.5]);
                for i = (handles.page)
                    name=char(chanlabels(handles.D{1},handles.order(i)));
                    %axes(ax1);
                    plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
                        handles.window,handles.plot_cond(handles.sel_cond), handles.order(i), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),ax1);
                    set(ax1,'color',[1 1 1]);
                    %if i==1
                        slice2d_axes_f = plot_slice_fig(handles.elecMatrix, handles.elecRgb, handles.V,i);
                    %else
                    %    move_2dslice(app.elecMatrix, app.elecRgb, app.V,i, slice2d_axes_f);
                    %end
                    %plot_slice(app.elecMatrix, app.elecRgb, app.V,i);
                end
            else
                set(f,'Position',[400 600 700 500]);
                set(f,'color',[1 1 1]);
                %disp('-------------Saving all figures--------------')
                
                ax1 = axes('Position',[0.1 0.1 0.85 0.85],'color',[1 1 1]);
                for i = (handles.page)
                    chanid = handles.order(i);
                    name=char(chanlabels(handles.D{1},handles.order(i)));
  
                    progress(i,length(handles.order),80,0)
                    
                    %axes(ax1);
                    plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
                        handles.window,handles.plot_cond(handles.sel_cond), handles.order(i), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),ax1);
                    set(ax1,'color',[1 1 1]);
                end
            end
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
%         plot_browser_b(handles.signal_all, handles.sparam,handles.labels,handles.D,...
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
%         plot_browser_b(handles.signal_all, handles.sparam,handles.labels,handles.D,...
%     handles.window,handles.plot_cond, handles.order(handles.page), handles.yl,handles.bch,handles.t)
guidata(hObject, handles);

function checkBoxCallback(hObject,eventdata,checkBoxId,handles)
hObject_b = hObject;
handles = guidata(gcf);
    handles.sel_cond(checkBoxId) = get(hObject_b,'Value');
   % axes(handles.axes1);
plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page),...
    handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
guidata(hObject, handles);


% --- Executes on button press in inspectBtn.
function inspectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to inspectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allt=handles.signal_all(handles.sel_cond);
alln=handles.nanid(handles.sel_cond);
newnan = data_inspection(allt,alln,handles.order(handles.page),handles.labels(handles.plot_cond(handles.sel_cond)),handles.window(round(handles.t*1000)==0));
for k=handles.plot_cond(handles.sel_cond)
    for j = 1:length(handles.signal_all{k})
        nanid = logical(newnan{k}{j});
        handles.nanid{k}{j}=nanid;
        try
            handles.signal_all{k}{j}(nanid)=nan;
        catch
            handles.signal_all{k}{j}(:,end+1) = nan;
        end
        %handles.signal_all{k}{j} = fillmissing(handles.signal_all{k}{j},'movmean',param*10);
    end
end
disp('.');
%disp('-----------Done------------');
%axes(handles.axes1);
plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
    handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
guidata(hObject, handles);


% --- Executes on button press in pushbutton12.


% --- Executes on button press in openBtn.
function openBtn_Callback(hObject, eventdata, handles)
% hObject    handle to openBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = spm_select(inf,'any','Select file to convert',{},pwd,'.edf');
[sodata] = spm_select(inf,'mat','Select SODATA for file',{},pwd,'.mat');
if isempty(filename) || isempty(sodata)
    return;
end
close(handles.figure1);
LBCN_preprocessing_new(filename,sodata);

% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*.mat','Data format (*.mat)'},...
                'MultiSelect', 'on');
            fname = fullfile(pathname,filename);
            if isempty(fname) || isempty(filename)
                return;
            else
                close(handles.figure1);
                if contains(fname,'Epoched','IgnoreCase',1)
                    LBCN_plot_HFB(fname);
                else
                    view_results(fname);
                end
            end

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.export.Enable = 'off';
handles.inspectBtn.Enable = 'off';
handles.savebtn.Enable = 'off';
handles.pushbutton2.Enable = 'off';
handles.pushbutton1.Enable = 'off';
handles.mripanel.Visible = 'off';
handles.popupmenu1.Enable = 'off';
handles.popupmenu3.Enable = 'off';
handles.popupmenu3.Value = 1;
handles.listbox1.Enable = 'off';
handles.listbox1.String = '';
handles.Button.Visible = 'off';
handles.openBtn.Enable = 'on';
handles.loadBtn.Enable = 'on';
cla(handles.axes1);
cla(handles.axes3);
handles.axes1.Visible = 'off';
handles.axes3.Visible = 'off';
delete(handles.slice2d_axes);
delete(handles.cbh);
handles.signal_all=[];
handles.slider1.Enable = 'off';
handles.slider2.Enable = 'off';
handles.slider3.Enable = 'off';
hObject.Enable = 'off';
handles.pushbutton9.Visible = 'off';
handles.pushbutton10.Visible = 'off';
guidata(hObject, handles);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = handles.popupmenu3.Value;
            Nt = length(handles.plot_cond);
            switch value
                case 'Set1'
                    handles.cc = brewermap(Nt,'Set1');%linspecer(Nt);
                case 'Set2'
                    handles.cc = brewermap(Nt,'Set2');%linspecer(Nt);
                case 'Set3'
                    handles.cc = linspecer(Nt);
                case 'Set4'
                    handles.cc = brewermap(Nt,'Dark2');
                case 'Paired'
                    handles.cc = brewermap(Nt,'Paired');
                case 'Parula'
                    handles.cc = colormap('parula');
            end
            close all;
            plot_browser_b(handles.signal_all(handles.sel_cond), handles.sparam,handles.labels,handles.D,...
            handles.window,handles.plot_cond(handles.sel_cond), handles.order(handles.page), handles.yl,handles.bch,handles.t,1,handles.cc(handles.sel_cond,:),handles.axes1);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
