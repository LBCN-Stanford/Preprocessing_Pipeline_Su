function varargout = ImageBrowser(varargin)
% IMAGEBROWSER MATLAB code for ImageBrowser.fig
%      IMAGEBROWSER, by itself, creates a new IMAGEBROWSER or raises the existing
%      singleton*.
%
%      H = IMAGEBROWSER returns the handle to a new IMAGEBROWSER or the handle to
%      the existing singleton*.
%
%      IMAGEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEBROWSER.M with the given input arguments.
%
%      IMAGEBROWSER('Property','Value',...) creates a new IMAGEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageBrowser

% Last Modified by GUIDE v2.5 14-Sep-2018 09:28:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImageBrowser_OpeningFcn, ...
    'gui_OutputFcn',  @ImageBrowser_OutputFcn, ...
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


% --- Executes just before ImageBrowser is made visible.
function ImageBrowser_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageBrowser (see VARARGIN)

% Choose default command line output for ImageBrowser
handles.output = hObject;

set(gcf, 'Name', 'LBCN Image Browser');



handles.sp1 = [];
handles.sp2=[];
handles.sp3=[];
handles.l=[];
handles.volume=[];
handles.page = 1;
handles.overlay = 0;
handles.curr_model = 0;
handles.begin = 0;
handles.Slider = com.jidesoft.swing.RangeSlider(1,100,30,70);  % min,max,low,high
handles.th1 = 0.3;
handles.th2 = 0.7;
handles.Slider = javacomponent(handles.Slider, [10,230,180,60], handles.uipanel2);
set(handles.Slider, 'MajorTickSpacing',1, 'PaintTicks', true, 'PaintLabels', false,'StateChangedCallback',{@sliderChangedCallback,handles});

% handles.Slider2 = com.jidesoft.swing.RangeSlider(0.01,1,0.4);  % min,max,low,high
% handles.Slider2 = javacomponent(handles.Slider2, [10,270,180,60], handles.uipanel2);
%set(handles.Slider2, 'MajorTickSpacing',1, 'PaintTicks', true, 'PaintLabels', false,'StateChangedCallback',{@sliderChangedCallback2,handles});
guidata(hObject, handles);


% UIWAIT makes ImageBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageBrowser_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function C = mouseMove(object, eventdata)
% C = get (gcf, 'CurrentPoint')
%      if C(1)>64 && C(1)< 120 && C(2)<27 
%          set(gca,handles.axes4);
%         rotate on
%     else
%         
%         
%     end

function scrollfunc(object, eventdata,GCA,handles)
 %   C=mouseMove (object, eventdata);

%    if C(2)<500
%         pt=handles.pointer3dt;
%         %ax = get(GCA,'tag');
%         xpos=round(pt(1,2)); ypos=round(pt(1,1));
%         zpos = handles.pointer3dt(3);
%         tpos = handles.pointer3dt(4);
%        
% %         switch ax
% %             case 'axes1'
%        handles.pointer3dt = [xpos+1 ypos zpos tpos];
% %             case 'axes2'
% %                  aa = [xpos ypos+1 zpos tpos];
% %             case 'axes3'
% %                  aa = [xpos+1 ypos zpos tpos];
%                 
%     [handles.sp1,handles.sp2,handles.sp3,handles.l] = ...
%     move3slices([], handles,'all',handles.sp1,handles.sp2,handles.sp3,handles.l);
% 
%     %handles.pointer3dt = [xpos ypos zpos tpos];
%     end

      

function ImageBrowserFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ImageBrowserFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%disp('ImageBrowserFigure_KeyPressFcn');
curr_char = int8(get(gcf,'CurrentCharacter'));
if isempty(curr_char)
    return;
end

xpos = handles.pointer3dt(1);
ypos = handles.pointer3dt(2);
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);
% Keys:
% - up:   30
% - down:   31
% - left:   28
% - right:   29
% - '1': 49
% - '2': 50
% - '3': 51
% - 'e': 101
% - plus:  43
% - minus:  45
switch curr_char
    case 99 % 'c'
        handles.color_mode = 1 - handles.color_mode;
        if (handles.color_mode ==1 && size(handles.volume,4) ~= 3)
            handles.color_mode = 0;
        end
        
    case 113 % 'q'
        handles.axis_equal = 1 - handles.axis_equal;
        
    case 30
        switch handles.last_axis_id
            case 1
                xpos = xpos -1;
            case 2
                xpos = xpos -1;
            case 3
                zpos = zpos -1;
            case 0
        end
    case 31
        switch handles.last_axis_id
            case 1
                xpos = xpos +1;
            case 2
                xpos = xpos +1;
            case 3
                zpos = zpos +1;
            case 0
        end
    case 28
        switch handles.last_axis_id
            case 1
                ypos = ypos -1;
            case 2
                zpos = zpos -1;
            case 3
                ypos = ypos -1;
            case 0
        end
    case 29
        switch handles.last_axis_id
            case 1
                ypos = ypos +1;
            case 2
                zpos = zpos +1;
            case 3
                ypos = ypos +1;
            case 0
        end
    case 43
        % plus key
        tpos = tpos+1;
    case 45
        % minus key
        tpos = tpos-1;
    case 49
        % key 1
        handles.last_axis_id = 1;
    case 50
        % key 2
        handles.last_axis_id = 2;
    case 51
        % key 3
        handles.last_axis_id = 3;
    case 101
        disp(['[' num2str(xpos) ' ' num2str(ypos) ' ' num2str(zpos) ' ' num2str(tpos) ']']);
    otherwise
        return
end
handles.page=zpos;
set(handles.show_page,'string',zpos);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
%[sp1 sp2 sp3] =
[handles.sp1,handles.sp2,handles.sp3,handles.l] = ...
    move3slices(hObject, handles,'all',handles.sp1,handles.sp2,handles.sp3,handles.l);


% Update handles structure
guidata(hObject, handles);

function [H1, H2, H3, H4] = plot3slices(hObject, handles)
% pointer3d     3D coordinates in volume matrix (integers)

handles.pointer3dt;
size(handles.volume{1});
i=1;
%for i = 1
    sliceXY = squeeze(handles.volume{i}(:,:,handles.pointer3dt(3),handles.pointer3dt(4)));
    sliceYZ = squeeze(handles.volume{i}(handles.pointer3dt(1),:,:,handles.pointer3dt(4)));
    sliceXZ = squeeze(handles.volume{i}(:,handles.pointer3dt(2),:,handles.pointer3dt(4)));
    
    max_xyz = max([ max(sliceXY(:)) max(sliceYZ(:)) max(sliceXZ(:)) ]);
    min_xyz = min([ min(sliceXY(:)) min(sliceYZ(:)) min(sliceXZ(:)) ]);
    clims = [ min_xyz max_xyz ];
    %end;
    sliceZY = squeeze(permute(sliceYZ, [2 1 3]));
    axes(handles.axes1);
    %sp1 = subplot(2,2,1);
    %colorbar;
    handles.sp1{i} = imagesc(sliceXY,clims);
    axis xy;
%    ax = get(gca,'Position');
%     ax(3) = ax(3)*1.4;
%     ax(4) = ax(4)*1.4;
%     ax(2) = ax(2)-0.12;
%     ax(1) = ax(1)-0.05;
%     set(gca,'Position',ax);
    hold on;
    %title('Slice XY');
    ylabel('X');
    %xlabel('Y');ax
    handles.l(1,1) = line(handles.axes1,[handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume{i},1)],'color',[202 247 202]/255,'linewidth',1);
    handles.l(1,2) = line(handles.axes1,[0 size(handles.volume{i},2)], [handles.pointer3dt(1) handles.pointer3dt(1)],'color',[202 247 202]/255,'linewidth',1);
    %set(allchild(gca),'ButtonDownFcn',@Subplot1_ButtonDownFcn);
    set(allchild(handles.axes1),'ButtonDownFcn',...
        'ImageBrowser(''Subplot1_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'xtick',[],'color','k');
    axis off
    if (handles.axis_equal == 1)
        axis image;
    else
        axis normal;
        %axis image;
    end
    %hold off;
    axes(handles.axes2);
    handles.sp2{i} = imagesc(sliceXZ,clims);
    axis xy;
    xlabel('Z');
    hold on
    handles.l(2,1) = line(handles.axes2,[handles.pointer3dt(3) handles.pointer3dt(3)], [0 size(handles.volume{i},1)],'color',[202 247 202]/255,'linewidth',1);
    handles.l(2,2) = line(handles.axes2,[0 size(handles.volume{i},3)], [handles.pointer3dt(1) handles.pointer3dt(1)],'color',[202 247 202]/255,'linewidth',1);
    %set(allchild(gca),'ButtonDownFcn',@Subplot2_ButtonDownFcn);
    set(allchild(gca),'ButtonDownFcn','ImageBrowser(''Subplot2_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'ytick',[],'color','k');
    axis off
    if (handles.axis_equal == 1)
        axis image;
    else
        axis normal;
    end
    %hold off;
    axes(handles.axes3);
    handles.sp3{i} = imagesc(sliceZY, clims);
    axis xy;
    ylabel('Z');
    xlabel('Y');
    hold on
    handles.l(3,1) = line(handles.axes3,[0 size(handles.volume{i},2)], [handles.pointer3dt(3) handles.pointer3dt(3)],'color',[202 247 202]/255,'linewidth',1);
    handles.l(3,2) = line(handles.axes3,[handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume{i},3)],'color',[202 247 202]/255,'linewidth',1);
    %set(allchild(gca),'ButtonDownFcn',@Subplot3_ButtonDownFcn);
    set(allchild(handles.axes3),'ButtonDownFcn','ImageBrowser(''Subplot3_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'color','k');
    axis off
    if (handles.axis_equal == 1)
        axis image;
    else
        axis normal;
    end
%end
%hold off;

if handles.overlay > 1
i = 2;
    
    sliceXY = squeeze(handles.volume{i}(:,:,handles.pointer3dt(3),handles.pointer3dt(4)));
    sliceYZ = squeeze(handles.volume{i}(handles.pointer3dt(1),:,:,handles.pointer3dt(4)));
    sliceXZ = squeeze(handles.volume{i}(:,handles.pointer3dt(2),:,handles.pointer3dt(4)));
    sliceXY(sliceXY<0)=0;
    sliceYZ(sliceYZ<0)=0;
    sliceXZ(sliceXZ<0)=0;
%     max_xyz = max([ max(sliceXY(:)) max(sliceYZ(:)) max(sliceXZ(:)) ]);
%     min_xyz = min([ min(sliceXY(:)) min(sliceYZ(:)) min(sliceXZ(:)) ]);
    clims = [5 150];
    %end;
    sliceZY = squeeze(permute(sliceYZ, [2 1 3]));
    %sp1 = subplot(2,2,1);
    %colorbar;
    axes(handles.axes1);
    hold on;
    handles.sp1{i} = imagesc(sliceXY, clims);
    alpha=data_norm(handles.sp1{i}.CData,5);
    handles.sp1{i}.AlphaData = alpha.*0.85;
    axis xy;
    %handles.l(1,1) = line(handles.axes1,[handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume{i},1)],'color',[202 247 202]/255);
    %handles.l(1,2) = line(handles.axes1,[0 size(handles.volume{i},2)], [handles.pointer3dt(1) handles.pointer3dt(1)],'color',[202 247 202]/255);
    %title('Slice XY');
    ylabel('X');
    %xlabel('Y');ax
   
    %set(allchild(gca),'ButtonDownFcn',@Subplot1_ButtonDownFcn);
    set(allchild(gca),'ButtonDownFcn',...
        'ImageBrowser(''Subplot1_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'xtick',[],'color',[0 0 0]);
    axis off
    hold off
    axes(handles.axes2);
    hold on;
    %sp2 = subplot(2,2,2);
    handles.sp2{i} = imagesc(sliceXZ, clims);
    alpha=data_norm(handles.sp2{i}.CData,5);
    handles.sp2{i}.AlphaData = alpha.*0.85;
    axis xy;
    xlabel('Z');
    %handles.l(2,1) = line(handles.axes2,[handles.pointer3dt(3) handles.pointer3dt(3)], [0 size(handles.volume{i},1)],'color',[202 247 202]/255);
    %handles.l(2,2) = line(handles.axes2,[0 size(handles.volume{i},3)], [handles.pointer3dt(1) handles.pointer3dt(1)],'color',[202 247 202]/255);
    %set(allchild(gca),'ButtonDownFcn',@Subplot2_ButtonDownFcn);
    set(allchild(handles.axes2),'ButtonDownFcn','ImageBrowser(''Subplot2_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'ytick',[],'color',[0 0 0]);
    axis off
    hold off
    %sp3 = subplot(2,2,3);
    axes(handles.axes3);
    hold on;
    handles.sp3{i} = imagesc(sliceZY, clims);
    alpha=data_norm(handles.sp3{i}.CData,5);
    handles.sp3{i}.AlphaData = alpha.*0.85;
    axis xy;
    ylabel('Z');
    xlabel('Y');
    %handles.l(3,1) = line(handles.axes3,[0 size(handles.volume{i},2)], [handles.pointer3dt(3) handles.pointer3dt(3)],'color',[202 247 202]/255);
    %handles.l(3,2) = line(handles.axes3,[handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume{i},3)],'color',[202 247 202]/255);
    %set(handles.axes3,allchild(gca),'ButtonDownFcn',@Subplot3_ButtonDownFcn);
    set(allchild(handles.axes3),'ButtonDownFcn','ImageBrowser(''Subplot3_ButtonDownFcn'',gca,[],guidata(gcbo))');
    %set(gca,'color',[0 0 0]);
    axis off
%     if (handles.axis_equal == 1)
%         axis image;
%     else
%         axis normal;
%     end
hold off
end
UpVector = [-sind(90), cosd(90), 0];
DAR      = get(handles.axes1, 'DataAspectRatio');
set(handles.axes1, 'CameraUpVector', DAR .* UpVector);
DAR      = get(handles.axes2, 'DataAspectRatio');
% set(handles.axes2, 'CameraUpVector', DAR .* UpVector);
% DAR      = get(handles.axes3, 'DataAspectRatio');
set(handles.axes3, 'CameraUpVector', DAR .* UpVector);
H1 = handles.sp1;
H2 = handles.sp2;
H3 = handles.sp3;
H4 = handles.l;
guidata(handles.figure1, handles);

function pointer3d_out = clipointer3d(pointer3d_in,vol_size)
pointer3d_out = pointer3d_in;
for p_id=1:4
    if (pointer3d_in(p_id) > vol_size{1}(p_id))
        pointer3d_out(p_id) = vol_size{1}(p_id);
    end
    if (pointer3d_in(p_id) < 1)
        pointer3d_out(p_id) = 1;
    end
end

% function keyboard_Callback(varargin)
% handles=guidata(varargin{1});
% 
% if strcmp(varargin{1,2}.Key,'return')
%     
%     ok_Btn_Callback(handles.ok_Btn, [], handles)
%     % detectBtn_Callback(handles.detectBtn,[],handles);
% end


% --- Executes on button press in openMRI.
function openMRI_Callback(hObject, eventdata, handles)
% hObject    handle to openMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]=uigetfile({'*.*','Data format (*.mat,*.nii)'},'Please select MRI file');
fpath = [pathname filename];
if filename==0
    return;
end
type = fpath(end-2:end);
handles.overlay = handles.overlay +1;
handles.curr_model=handles.overlay;
set(handles.info,'string','Loading..');
pause(0.2);
if strcmp(type, 'mat')
    load(fpath);
elseif strcmp(type,'nii')
    volume = spm_read_vols(spm_vol(fpath));
    %hold on
%     set(handles.loadBtn,'enable','on');
%     set(handles.regBtn,'enable','on');
    set(handles.addBtn,'enable','on');
    for i=1:handles.overlay
        list{i}=strcat('Layer',' ',num2str(i));
    end
    set(handles.surf_list,'string',list,'visible','on','value',handles.curr_model);
    %set(handles.col_surf_Btn,'visible','on');
    %set(handles.del_surf_Btn,'visible','on');
    %set(handles.selBtn,'enable','on');
    handles.begin=1;
    %set(handles.show_ct_check,'visible','on');
    %set(handles.info,'string','');
    guidata(hObject, handles);
else
    errordlg('Unrecognized data.', 'Wrong data format');
    return;
end
mri = volume;
handles.vol{handles.overlay} = mri;
handles.axes1;
if (ndims(volume) ~= 3 && ndims(volume) ~= 4)
    error('Input volume must have 3 or 4 dimensions.');
end
handles.volume{handles.overlay} = volume;
handles.axis_equal = 0;
handles.color_mode = 1;
if (size(volume,4) ~= 3)
    handles.color_mode = 0;
end
% init 3D pointer
vol_sz = size(volume);
if (ndims(volume) == 3)
    vol_sz(4) = 1;
end
pointer3dt = floor(vol_sz/2)+1;
handles.pointer3dt = pointer3dt;
handles.page=handles.pointer3dt(1);
handles.vol_sz{handles.overlay} = vol_sz;
handles.page=pointer3dt(3);
set(handles.show_page,'string',handles.page);
set(handles.surf_list,'enable','on');
set(handles.openCT,'enable','on');

set(handles.info,'string','Rendering..');
pause(0.2);
[handles.sp1, handles.sp2, handles.sp3, handles.l] = plot3slices(hObject, handles);
% stores ID of last axis window
% (0 means that no axis was clicked yet)
handles.last_axis_id = 0;
set (gcf, 'WindowButtonMotionFcn', @mouseMove);
    handles.begin =1;
set(handles.figure1,'windowscrollWheelFcn', {@scrollfunc,gca, handles});
axes(handles.axes4);
v=imresize3(volume,0.7);
v=smooth3(v,'gaussian',3);
vol3d('cdata',v,'texture','3D');
colormap(gray);
view(3); 
%rotate3d;
axis vis3d
axis equal off
set(gca,'color',[0 0 0]);
xlim([30 200]);ylim([30 200]);zlim([30 200]);
set(handles.uipanel1,'visible','on');
% Update handles structure
guidata(hObject, handles);
set(handles.info,'string','Done..');
pause(0.2);
set(handles.info,'string',' ');


% --- Executes on button press in openCT.
function openCT_Callback(hObject, eventdata, handles)
% hObject    handle to openCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]=uigetfile({'*.*','Data format (*.mat,*.nii)'},'Please select CT file');
fpath = [pathname filename];
if filename==0
    return;
end
handles.overlay = handles.overlay +1;
handles.curr_model = handles.overlay;
type = fpath(end-2:end);
set(handles.info,'string','Loading..');
pause(0.2);
if strcmp(type, 'mat')
    load(fpath);
elseif strcmp(type,'nii')
    ct = spm_read_vols(spm_vol(fpath));
    %hold on
    for i=1:handles.overlay-1
        list{i}=strcat('Layer',' ',num2str(i));
    end
    list{handles.overlay}=strcat('Layer',' ',num2str(i)+1,' ','(CT)');
    set(handles.surf_list,'string',list,'visible','on','value',handles.curr_model);
    guidata(hObject, handles);
else
    errordlg('Unrecognized data.', 'Wrong data format');
    return;
end

handles.ct = ct;
axes(handles.axes4);
hold on;
ct = imresize3(ct,0.7);
set(handles.info,'string','Patching..');
pause(0.2);
show_ct_skull(ct);
hold off;
handles.axes1;
handles.shift=0;
% handles.vol=handles.vol/max(handles.vol(:));
% vol=handles.vol;
handles.th1=0;
handles.th2=0.05;
handles.th3=0.1;
handles.th4=0.2;
volume = handles.ct;
if (ndims(volume) ~= 3 && ndims(volume) ~= 4)
    error('Input volume must have 3 or 4 dimensions.');
end
handles.volume{handles.overlay} = volume;
handles.axis_equal = 0;
handles.color_mode = 1;
if (size(volume,4) ~= 3)
    handles.color_mode = 0;
end
% init 3D pointer
vol_sz = size(volume);
if (ndims(volume) == 3)
    vol_sz(4) = 1;
end

set(handles.info,'string','Initializeing..');
pause(0.2);

pointer3dt = floor(vol_sz/2)+1;
handles.pointer3dt = pointer3dt;
handles.vol_sz{handles.overlay} = vol_sz;
handles.page=pointer3dt(3);
set(handles.show_page,'string',handles.page);
[handles.sp1, handles.sp2, handles.sp3, handles.l] = plot3slices(hObject, handles);
% stores ID of last axis window
% (0 means that no axis was clicked yet)
handles.last_axis_id = 0;

set(gcf,'windowkeyreleasefcn',{@ImageBrowserFigure_KeyPressFcn,handles});
set(handles.Slider, 'MajorTickSpacing',1, 'PaintTicks', true, 'PaintLabels', ...
    false,'StateChangedCallback',{@sliderChangedCallback,handles});
set(handles.uipanel4,'visible','on');

xmoveModel = javax.swing.SpinnerNumberModel(0,-127,127,2);
ymoveModel = javax.swing.SpinnerNumberModel(0,-127,127,2);
zmoveModel = javax.swing.SpinnerNumberModel(0,-127,127,2);
scaleModel = javax.swing.SpinnerNumberModel(1,0,3,0.05);
xrotateModel = javax.swing.SpinnerNumberModel(0,-180,180,5);
yrotateModel = javax.swing.SpinnerNumberModel(0,-180,180,5);
zrotateModel = javax.swing.SpinnerNumberModel(0,-180,180,5);
% jSpinner = javax.swing.JSpinner(jModel);
% handles.jhSpinner = javacomponent(jSpinner, [50,100,60,30], handles.uipanel2, @monthYearChangedCallback);
%zrotate = javax.swing.SpinnerListModel(months);
handles.xmove = addLabeledSpinner('',xmoveModel,[50,170,50,30], {@xmoveChangedCallback,handles}, handles.uipanel2);
handles.ymove = addLabeledSpinner('',ymoveModel,[100,170,50,30], {@ymoveChangedCallback,handles}, handles.uipanel2);
handles.zmove = addLabeledSpinner('',zmoveModel,[150,170,50,30], {@zmoveChangedCallback,handles}, handles.uipanel2);
handles.xscale = addLabeledSpinner('',scaleModel,[50,120,50,30], {@xscaleChangedCallback,handles}, handles.uipanel2);
handles.xrotate = addLabeledSpinner('',xrotateModel,[50,70,50,30], {@xrotateChangedCallback,handles}, handles.uipanel2);
handles.yrotate = addLabeledSpinner('',yrotateModel,[100,70,50,30], {@yrotateChangedCallback,handles}, handles.uipanel2);
handles.zrotate = addLabeledSpinner('',zrotateModel,[150,70,50,30], {@zrotateChangedCallback,handles}, handles.uipanel2);

set(handles.xmove,'StateChangedCallback',{@xmoveChangedCallback,handles});
set(handles.ymove,'StateChangedCallback',{@ymoveChangedCallback,handles});
set(handles.zmove,'StateChangedCallback',{@zmoveChangedCallback,handles});
set(handles.xrotate,'StateChangedCallback',{@xrotateChangedCallback,handles});
set(handles.yrotate,'StateChangedCallback',{@yrotateChangedCallback,handles});
set(handles.zrotate,'StateChangedCallback',{@zrotateChangedCallback,handles});
set(handles.uipanel2,'visible','on');
%[handles.spin,~,~,~] = findjobj(gcf,'class','MJSpinner');
guidata(hObject, handles);
set(handles.info,'string','Done..');
pause(0.2);
set(handles.info,'string',' ');
pause(0.2);

% --- Executes on selection change in surf_list.
function surf_list_Callback(hObject, eventdata, handles)
% hObject    handle to surf_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns surf_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from surf_list


% --- Executes during object creation, after setting all properties.
function surf_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surf_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','Fontname','Optima');
end


% --- Executes on button press in addBtn.
function addBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);


function Subplot1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the XY slice

%disp('Subplot1:BtnDown');
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); ypos=round(pt(1,1));
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
%handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
%plot3slices(hObject, handles);
if isfield(handles,'ct')
    ch = get(handles.axes1,'child');
    handles.sp1{2} = ch(1);
    handles.sp1{1} = ch(4);
    handles.l(1,:)=[ch(2) ch(3)];
    ch = get(handles.axes2,'child');
    handles.sp2{2} = ch(1);
    handles.sp2{1} = ch(4);
    handles.l(2,:)=[ch(2) ch(3)];
    ch = get(handles.axes3,'child');
    handles.sp3{2} = ch(1);
    handles.sp3{1} = ch(4);
    handles.l(3,:)=[ch(2) ch(3)];
end

[handles.sp1,handles.sp2,handles.sp3,handles.l] = ...
    move3slices(hObject, handles,1,handles.sp1,handles.sp2,handles.sp3,handles.l);



% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(handles.figure1, handles);
clc
% --- Executes on mouse press over axes background.
function Subplot2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the YZ slice

%disp('Subplot2:BtnDown');
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); zpos=round(pt(1,1));
ypos = handles.pointer3dt(2);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.page=zpos;
set(handles.show_page,'string',zpos);
if isfield(handles,'ct')
    ch = get(handles.axes1,'child');
    handles.sp1{2} = ch(1);
    handles.sp1{1} = ch(4);
    handles.l(1,:)=[ch(2) ch(3)];
    ch = get(handles.axes2,'child');
    handles.sp2{2} = ch(1);
    handles.sp2{1} = ch(4);
    handles.l(2,:)=[ch(2) ch(3)];
    ch = get(handles.axes3,'child');
    handles.sp3{2} = ch(1);
    handles.sp3{1} = ch(4);
    handles.l(3,:)=[ch(2) ch(3)];
end
%handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
[handles.sp1,handles.sp2,handles.sp3,handles.l] =move3slices(hObject, handles,2,handles.sp1,handles.sp2,handles.sp3,handles.l);
% store this axis as last clicked region
handles.last_axis_id = 2;
% Update handles structure
guidata(handles.figure1, handles);

% --- Executes on mouse press over axes background.
function Subplot3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the XZ slice

%disp('Subplot3:BtnDown');
pt=get(gca,'currentpoint');
zpos=round(pt(1,2)); ypos=round(pt(1,1));
xpos = handles.pointer3dt(1);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.page=zpos;
set(handles.show_page,'string',zpos);
if isfield(handles,'ct')
    ch = get(handles.axes1,'child');
    handles.sp1{2} = ch(1);
    handles.sp1{1} = ch(4);
    handles.l(1,:)=[ch(2) ch(3)];
    ch = get(handles.axes2,'child');
    handles.sp2{2} = ch(1);
    handles.sp2{1} = ch(4);
    handles.l(2,:)=[ch(2) ch(3)];
    ch = get(handles.axes3,'child');
    handles.sp3{2} = ch(1);
    handles.sp3{1} = ch(4);
    handles.l(3,:)=[ch(2) ch(3)];
end
%handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
[handles.sp1,handles.sp2,handles.sp3,handles.l] = move3slices(hObject, handles,3,handles.sp1,handles.sp2,handles.sp3,handles.l);
% store this axis as last clicked region
handles.last_axis_id = 3;
% Update handles structure
guidata(handles.figure1, handles);

function xmoveChangedCallback(jSpinner,jEventData, handles)
in = handles.volume{2};
ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;
% 
% in = imtranslate(in,[ -shiftx*tan(angley) 0 shiftx*cos(angley)]);
% in = imtranslate(in,[shifty*cos(anglez) -shifty*tan(anglez) 0]);

in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);

in = rotate_volume(in, anglez, 3);
in = rotate_volume(in, angley, 2);
handles.volume{2} = rotate_volume(in, anglex, 1);
%try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
% catch
%     [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% end
guidata(handles.figure1,handles);
% shift = jSpinner.getValue;
% %shift=0;
% handles.volume{2} = imtranslate(in,[shift 0 0],'FillValues',0);
% [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% guidata(handles.figure1,handles);
%plot3slices(jSpinner, handles);

function ymoveChangedCallback(jSpinner,jEventData, handles)
in = handles.volume{2};
ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;

in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);

in = rotate_volume(in, anglez, 3);
in = rotate_volume(in, angley, 2);
handles.volume{2} = rotate_volume(in, anglex, 1);
%try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
% catch
%     [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% end
guidata(handles.figure1,handles);
% shift = jSpinner.getValue;
% %shift=0;
% handles.volume{2} = imtranslate(in,[0 shift 0],'FillValues',0);
% [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% guidata(handles.figure1,handles);

function zmoveChangedCallback(jSpinner,jEventData, handles)
in = handles.volume{2};
ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;

in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);

in = rotate_volume(in, anglez, 3);
in = rotate_volume(in, angley, 2);
handles.volume{2} = rotate_volume(in, anglex, 1);
%try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
% catch
%     [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% end
guidata(handles.figure1,handles);
% shift = jSpinner.getValue;
% %shift=0;
% handles.volume{2} = imtranslate(in,[0 0 shift],'FillValues',0);
% [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
% guidata(handles.figure1,handles);

function xrotateChangedCallback(jSpinner,jEventData, handles)
ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

in = handles.volume{2};
shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);

anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;
in = rotate_volume(in, anglez, 3);
in = rotate_volume(in, angley, 2);
handles.volume{2} = rotate_volume(in, anglex, 1);
try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
catch
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
end
guidata(handles.figure1,handles);

function yrotateChangedCallback(jSpinner,jEventData, handles)

ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

in = handles.volume{2};
shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;
in = rotate_volume(in, anglex, 1);
in = rotate_volume(in, anglez, 3);
handles.volume{2} = rotate_volume(in, angley, 2);
try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
catch
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
end
guidata(handles.figure1,handles);

% --- Executes on button press in pushbutton7.
function zrotateChangedCallback(jSpinner,jEventData, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%in=getappdata(handles.figure1,'vol');
ch = get(handles.axes1,'child');
H1{2} = ch(1);H1{1} = ch(4);
H4(1,:)=[ch(2) ch(3)];
ch = get(handles.axes2,'child');
H2{2} = ch(1);H2{1} = ch(4);

H4(2,:)=[ch(2) ch(3)];
ch = get(handles.axes3,'child');
H3{2} = ch(1);H3{1} = ch(4);
H4(3,:)=[ch(2) ch(3)];

in = handles.volume{2};
% ax=handles.figure1.CurrentAxes;
% pt=get(ax,'currentpoint');
% xpos=round(pt(1,2)); 
% zpos=round(pt(1,1));
% ypos = handles.pointer3dt(2);
% tpos = handles.pointer3dt(4);
% handles.pointer3dt = [xpos ypos zpos tpos];
% handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);

shiftx = handles.xmove.getValue;
shifty = handles.ymove.getValue;
shiftz = handles.zmove.getValue;
in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;
in = rotate_volume(in, anglex, 1);
in = rotate_volume(in, angley, 2);
handles.volume{2} = rotate_volume(in, anglez, 3);
%handles.volume{2} = imrotate3(in, anglez,[0 0 1],'linear','crop' );
try
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jSpinner,  handles,'all', H1, H2, H3, H4);
catch
    [handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
end

guidata(handles.figure1,handles);
%plot3slices(jSpinner, handles);
%inCallback = 0;

function xscaleChangedCallback(jSpinner,jEventData, handles)
[handles.sp1,handles.sp2,handles.sp3,handles.l]=plot3slices(jSpinner, handles);
%guidata(hObject, handles);

function jhSpinner = addLabeledSpinner(label,model,pos,callbackFunc,p)
      % Set the spinner control
      jSpinner = com.mathworks.mwswing.MJSpinner(model);
      %jTextField = jSpinner.getEditor.getTextField;
      %jTextField.setHorizontalAlignment(jTextField.RIGHT);  % unneeded
      jhSpinner = javacomponent(jSpinner,pos,p);
      jhSpinner.setToolTipText('<html>This spinner is editable, but only the<br/>preconfigured values can be entered')
      set(jhSpinner,'StateChangedCallback',callbackFunc);
      %set(jhSpinner,'Background',[0.97 0.97 0.97]);
      % Set the attached label
      jLabel = com.mathworks.mwswing.MJLabel(label);
      jLabel.setLabelFor(jhSpinner);
      %jLabel.setBackground([0.97 0.97 0.97]*255);
      if jLabel.getDisplayedMnemonic > 0
          hotkey = char(jLabel.getDisplayedMnemonic);
          jLabel.setToolTipText(['<html>Press <b><font color="blue">Alt-' hotkey '</font></b> to focus on<br/>adjacent spinner control']);
      end

      %jhLabel = javacomponent(jLabel,pos,hFig);% addLabeledSpinner
      
      
function sliderChangedCallback(jobject,~,handles)
th1=jobject.LowValue;
th2=jobject.HighValue;
% ch = get(handles.axes1,'child');
% H1{2} = ch(1);H1{1} = ch(4);
% H4(1,:)=[ch(2) ch(3)];
% ch = get(handles.axes2,'child');
% H2{2} = ch(1);H2{1} = ch(4);
% 
% H4(2,:)=[ch(2) ch(3)];
% ch = get(handles.axes3,'child');
% H3{2} = ch(1);H3{1} = ch(4);
% H4(3,:)=[ch(2) ch(3)];

J = imadjust(handles.ct(:)./max(handles.ct(:)),[th1/100; th2/100],[0; 1]);
handles.volume{2}=reshape(J,size(handles.volume{2}));
[handles.sp1,handles.sp2,handles.sp3,handles.l]=move3slices(jobject,  handles,'all', handles.sp1, handles.sp2, handles.sp3, handles.l);
%guidata(handles.figure1,handles);

function sliderChangedCallback2(jobject,~,handles)
      


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on selection change in colorpop.
function colorpop_Callback(hObject, eventdata, handles)
% hObject    handle to colorpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String')) ;
a = contents{get(hObject,'Value')};
switch a
    case 'Gray Scale'
    case 'Color'
        
%         handles.sp1{1}.CData = ind2rgb(handles.sp1{1}.CData,brewermap([],'*purples'));
%         handles.sp2{1}.CData = ind2rgb(handles.sp2{1}.CData,brewermap([],'*purples'));
%         handles.sp3{1}.CData = ind2rgb(handles.sp3{1}.CData,brewermap([],'*purples'));
%         handles.sp1{2}.CData = ind2rgb(handles.sp1{2}.CData,brewermap([],'*ylorbr'));
%         handles.sp2{2}.CData = ind2rgb(handles.sp2{2}.CData,brewermap([],'*ylorbr'));
%         handles.sp3{2}.CData = ind2rgb(handles.sp3{2}.CData,brewermap([],'*ylorbr'));
end
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns colorpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorpop


% --- Executes during object creation, after setting all properties.
function colorpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.info,'string','Saving...');
pause(0.2);
shiftx = handles.xmove.getValue;
shifty = handles.xmove.getValue;
shiftz = handles.xmove.getValue;
in = handles.ct;
in = imtranslate(in,[shiftx 0 0]);
in = imtranslate(in,[0 shifty 0]);
in = imtranslate(in,[0 0 shiftz]);
anglez = handles.zrotate.getValue;
anglex = handles.xrotate.getValue;
angley = handles.yrotate.getValue;
in = rotate_volume(in, anglex, 1);
in = rotate_volume(in, angley, 2);
outct = rotate_volume(in, anglez, 3);
niftiwrite(outct,'CT_new.nii','Compressed',true);
%uisave(outfile,'new_image.nii');
set(handles.info,'string','File saved to the current folder.');
