function varargout = data_inspection(varargin)
% DATA_INSPECTION MATLAB code for data_inspection.fig
%      DATA_INSPECTION, by itself, creates a new DATA_INSPECTION or raises the existing
%      singleton*.
%
%      H = DATA_INSPECTION returns the handle to a new DATA_INSPECTION or the handle to
%      the existing singleton*.
%
%      DATA_INSPECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_INSPECTION.M with the given input arguments.
%
%      DATA_INSPECTION('Property','Value',...) creates a new DATA_INSPECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_inspection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_inspection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_inspection

% Last Modified by GUIDE v2.5 14-Aug-2018 16:13:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_inspection_OpeningFcn, ...
                   'gui_OutputFcn',  @data_inspection_OutputFcn, ...
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

% --- Executes just before data_inspection is made visible.
function data_inspection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_inspection (see VARARGIN)

% Choose default command line output for data_inspection
handles.allt=varargin{1};
handles.alln=varargin{2};
handles.index=varargin{3};
handles.condname=varargin{4};
handles.t0=varargin{5};
handles.page=1;
set(handles.popupmenu1,'string',handles.condname,'value',1);
j=1;
sig =  handles.allt{j}{handles.index};
vs=nanvar(sig);
elim=vs>5*nanmedian(vs);
%fb = find(nansum(sig)==0);
handles.fb = elim;
null=nan(size(sig));alln = handles.alln{j}{handles.index};%sn = size(handles.alln{j}{handles.index}); sn2=size(null);if sn(2) ~= sn2(2);alln(:,sn2(2))=false(sn2(1),1);end
null(logical(alln))=1;
null(:,handles.fb)=1;
red=null.*sig;
  %f=figure;

handles.P=tight_subplot(8,5,[.03 .03],[.02 .05],[.02 .02]);

if size(sig,2)>40
   
    set(handles.pushbutton1,'visible','on');
    set(handles.pushbutton2,'visible','on');
else
   set(handles.pushbutton1,'visible','off');
    set(handles.pushbutton2,'visible','off');
end
for n=1:40
    axes(handles.P(n));
    try
        plot(sig(:,n),'k','linewidth',2);
        hold on
        plot(red(:,n),'r','linewidth',2);
        line([0 size(sig,1)],[0 0],'color','k','linewidth',1);
        xlim([0 size(sig,1)]);
        box off;
        %axis off;
        set(gca,'visible','on','tag',num2str(n),'linewidth',1,'xtick',[],'fontsize',14,'color',[0.98 0.98 0.98],'ticklength',[0 0]);
        yl = get(gca,'ylim');
        line([handles.t0 handles.t0],yl,'color','k','linewidth',1);
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        title(strcat(num2str((n))));
%         handles.c(n) = uicontrol('style','checkbox','units','normalized',...
%                 'position',pa,'value',0);
       set(gca,'ButtonDownFcn',@getMousePositionOnImage); 
    catch
        set(handles.P(n),'visible','off');
        %break;
    end
    
    
    %                                 if n == 41 && n2<(size(sig,2))
    %                                     n = 1;
    %                                     figure;  
    
end
%set(handles.figure1,'Position',[0.2 0.2 800 1100]);
handles.sig=sig;
handles.red=red;
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
waitfor(handles.figure1,'name');
% UIWAIT makes data_inspection wait for user response (see UIRESUME)
 %uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_inspection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.output = handles.alln;
% Get default command line output from handles structure
(set(gcf,'name','Quitting...'));
varargout{1} = handles.alln;
close gcf


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% contents = cellstr(get(hObject,'String'));
% j = contents{get(hObject,'Value')} ;
j = get(hObject,'Value');
sig =  handles.allt{j}{handles.index};
vs=nanvar(sig);
elim=vs>5*nanmedian(vs);
%fb = find(nansum(sig)==0);
fb = elim;
null=nan(size(sig));
null(logical(handles.alln{j}{handles.index}))=1;
null(:,fb)=1;
red=null.*sig;
  %f=figure;

%handles.P=tight_subplot(8,5,[.05 .05],[.05 .05],[.05 .05]);
if size(sig,2)>40
    set(handles.pushbutton1,'visible','on');
    set(handles.pushbutton2,'visible','on');
else
    set(handles.pushbutton1,'visible','off');
    set(handles.pushbutton2,'visible','off');
end
for n=1:40
    axes(handles.P(n));
    cla;
    try
        plot(sig(:,n),'k','linewidth',2);
        hold on
        plot(red(:,n),'r','linewidth',2);
       line([0 size(handles.sig,1)],[0 0],'color','k','linewidth',1);
        xlim([0 size(handles.sig,1)]);
        box off;
        %axis off;
        set(gca,'visible','on','tag',num2str(n),'linewidth',1,'xtick',[],'fontsize',14,'color',[0.98 0.98 0.98],'ticklength',[0 0]);
        yl = get(gca,'ylim');
        line([handles.t0 handles.t0],yl,'color','k','linewidth',1);
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        title(strcat(num2str((n))));
    catch
        set(gca,'visible','off');
        %break;
    end   
end
%set(handles.figure1,'Position',[0.2 0.2 800 1100]);
handles.sig=sig;
handles.red=red;
handles.page=1;
% Update handles structure
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page < ceil(size(handles.sig,2)/40)
handles.page=handles.page+1;
n2=40*(handles.page-1)+1;
for n=1:40
    axes(handles.P(n));
    cla;
    try
        plot(handles.sig(:,n2),'k','linewidth',2);
        hold on
        plot(handles.red(:,n2),'r','linewidth',2);
       line([0 size(handles.sig,1)],[0 0],'color','k','linewidth',1);
        xlim([0 size(handles.sig,1)]);
        box off;
        %axis off;
        set(gca,'visible','on','tag',num2str(n2),'linewidth',1,'xtick',[],'fontsize',14,'color',[0.98 0.98 0.98],'ticklength',[0 0]);
        yl = get(gca,'ylim');
        line([handles.t0 handles.t0],yl,'color','k','linewidth',1);
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        title(strcat(num2str((n2))));
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        n2=n2+1;
    catch
        set(gca,'visible','off');
    end
end
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.page >1 
handles.page=handles.page-1;
n2=40*(handles.page-1)+1;
for n=1:40
    axes(handles.P(n));
    cla;
    try
        plot(handles.sig(:,n2),'k','linewidth',2);
        hold on
        plot(handles.red(:,n2),'r','linewidth',2);
     line([0 size(handles.sig,1)],[0 0],'color','k','linewidth',1);
        xlim([0 size(handles.sig,1)]);
        box off;
        %axis off;
        set(gca,'visible','on','tag',num2str(n2),'linewidth',1,'xtick',[],'fontsize',14,'color',[0.98 0.98 0.98],'ticklength',[0 0]);
        yl = get(gca,'ylim');
        line([handles.t0 handles.t0],yl,'color','k','linewidth',1);
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        title(strcat(num2str((n2))));
        %set(gca,'linewidth',2,'xtick',[],'fontsize',14,'visible','on','tag',num2str(n),'color',[0.98 0.98 0.98]);
        n2=n2+1;
    catch
        set(gca,'visible','off');
    end
end
end
guidata(hObject, handles);

    
function getMousePositionOnImage(src, event)
handles = guidata(src);
rec=get(gca,'ylim');
set(gca,'color',[1 1 1]);box on
[x,y,d]=selectdata('lim_h',rec(1),'lim_u',rec(2),'fillcolor',[0.68 0.92 1],'Identify', 'on','pointer','crosshair');%,'SelectionMode' ,'closest');
aid = get(gca,'tag');
tid = str2num(aid);
cond = get(handles.popupmenu1,'Value');
try
handles.alln{cond}{handles.index}(x{end},tid)=true;
handles.red(x{end},tid)=handles.allt{cond}{handles.index}(x{end},tid);
hold on;
plot(handles.red(:,tid),'r','linewidth',2);
catch
end
%axis off
set(gca,'color',[0.98 0.98 0.98],'linewidth',1,'xtick',[],'fontsize',14,'ticklength',[0 0]);box off
guidata(src,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'Name','Quitting...');

guidata(hObject, handles);
