function varargout = relabel(varargin)
% RELABEL MATLAB code for relabel.fig
%      RELABEL, by itself, creates a new RELABEL or raises the existing
%      singleton*.
%
%      H = RELABEL returns the handle to a new RELABEL or the handle to
%      the existing singleton*.
%
%      RELABEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RELABEL.M with the given input arguments.
%
%      RELABEL('Property','Value',...) creates a new RELABEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before relabel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to relabel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help relabel

% Last Modified by GUIDE v2.5 19-Oct-2018 01:26:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @relabel_OpeningFcn, ...
                   'gui_OutputFcn',  @relabel_OutputFcn, ...
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


% --- Executes just before relabel is made visible.
function relabel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to relabel (see VARARGIN)

handles.eeglabel = varargin{1};
handles.mrilabel = varargin{2};
handles.newlabel = cell(size(handles.eeglabel));
handles.curr = 1;
set(handles.listbox1,'string',handles.mrilabel,'fontsize',14);
set(handles.text3,'string',handles.eeglabel{1});
set(handles.figure1,'name','Cannot correlate channel labels with image data')
po = get(handles.text3,'position');
po2 = get(handles.edit1,'position');
n = length(handles.eeglabel);
for i = 1:length(handles.eeglabel)
     
   handles.oldedit(i) = uicontrol('unit','normalized','style','text','position',...
       [po(1)+0.01 0.1+(i)*((po(2))/(1.2*length(handles.eeglabel))) po(3) po(4)],...
       'string',handles.eeglabel(i),'fontname','optima','fontsize',12,...
       'HorizontalAlignment','left','tag',strcat('l',num2str(n)));
   handles.newedit(i) = uicontrol('unit','normalized','style','edit','position',...
       [po2(1)+0.01 0.1+(i)*((po2(2))/(1.2*length(handles.eeglabel))) po2(3) po2(4)],'string','',...
       'fontsize',12,'tag',num2str(n),'backgroundcolor',[0.94 0.94 0.94]);
   n=n-1;
end
set(handles.oldedit(length(handles.eeglabel)),'foregroundcolor', [0.67 0.28 0]);
set(gcf,'WindowKeyPressFcn',{@keyPressCallback,handles});
delete(handles.edit1);
delete(handles.text3);
%handles.newedit(i-1) = handles.edit1;
% Choose default command line output for relabel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes relabel wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = relabel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% for i =length(handles.eeglabel):-1:1
%     handles.newlabels{i}=get(handles.newedit(i),'string');
% end
for i = 1:length(handles.newedit)
    %try
    if ~isempty(handles.newedit(i))
        handles.newlabel{i}=get(handles.newedit(i),'string');
    %catch
    else
        handles.newlabel{i}=get(handles.oldedit(i),'string');
    end
end
%handles.newlabels=get(handles.listbox1,'string');
handles.output = handles.newlabel;
eeglabelnew = handles.newlabel;
guidata(hObject, handles);

assignin('caller','eeglabelnew',eeglabelnew);
assignin('base','eeglabelnew',eeglabelnew);
%close(gcf);
uiresume;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eeglabelnew = handles.eeglabel;
assignin('caller','eeglabelnew',eeglabelnew);
assignin('base','eeglabelnew',eeglabelnew);
%guidata(hObject, handles);
close(gcf);
%uiresume;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'value');
newlb = handles.mrilabel(val);
curr_box = findobj('tag',num2str(handles.curr));
set(curr_box, 'string', newlb);
listcont = get(hObject,'string');
listcont(val) = strcat(newlb,' (selected)');
set(hObject,'String',listcont);
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function keyPressCallback(source,eventdata,handles)
 keyPressed = eventdata.Key;
 if (strcmpi(keyPressed,'comma') || strcmpi(keyPressed,'leftarrow')) && handles.curr > 1
     handles.curr = handles.curr-1;
     curr_box = findobj('tag',num2str(handles.curr));
     curr_lab = findobj('tag',strcat('l',num2str(handles.curr)));
     set(curr_box,'selected','on','backgroundcolor',[1 1 1]);
     set(curr_lab,'foregroundcolor',[0.67 0.28 0]);
     prev = findobj('tag',num2str(handles.curr+1));
     set(prev,'selected','off','backgroundcolor',[0.94 0.94 0.94]);
     prevl = findobj('tag',strcat('l',num2str(handles.curr+1)));
     set(prevl,'foregroundcolor',[0 0 0]);
 elseif (strcmpi(keyPressed,'period') || strcmpi(keyPressed,'rightarrow') )&& handles.curr < length(handles.eeglabel)
     handles.curr = handles.curr+1;
     curr_box = findobj('tag',num2str(handles.curr));
     set(curr_box,'selected','on','backgroundcolor',[1 1 1]);
     curr_lab = findobj('tag',strcat('l',num2str(handles.curr)));
     set(curr_lab,'foregroundcolor',[0.67 0.28 0]);
     prev = findobj('tag',num2str(handles.curr-1));
     set(prev,'selected','off','backgroundcolor',[0.94 0.94 0.94]);
     prevl = findobj('tag',strcat('l',num2str(handles.curr-1)));
     set(prevl,'foregroundcolor',[0 0 0]);
 end
 guidata(source, handles);
 set(gcf,'WindowKeyPressFcn',{@keyPressCallback,handles});
