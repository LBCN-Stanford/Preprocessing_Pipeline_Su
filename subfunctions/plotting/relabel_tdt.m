function varargout = relabel_tdt(varargin)
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

% Last Modified by GUIDE v2.5 11-Oct-2018 21:38:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @relabel_tdt_OpeningFcn, ...
                   'gui_OutputFcn',  @relabel_tdt_OutputFcn, ...
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
function relabel_tdt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to relabel (see VARARGIN)
handles.eeglabel = varargin{1};
handles.mrilabel = varargin{2};
handles.selection = [];
handles.newlabel = cell(size(handles.eeglabel));
set(handles.listbox1,'string',handles.eeglabel,'fontsize',12,'max',length(handles.eeglabel),'min',0);
set(handles.text3,'string',handles.mrilabel{1});
set(handles.figure1,'name','Channel Relabel')
po = get(handles.text3,'position');
po2 = get(handles.edit1,'position');
for i = 1:length(handles.mrilabel)
     
   uicontrol('unit','normalized','style','pushbutton','position',...
       [po(1)+0.01 0.1+(i)*((po(2))/(1.2*length(handles.mrilabel))) po(3) po(4)],...
       'string',handles.mrilabel(i),'fontname','optima','fontsize',12,...
       'HorizontalAlignment','left','callback',{@pb_call,handles});
   handles.newedit(i) = uicontrol('unit','normalized','style','text','position',...
       [po2(1)+0.01 0.1+(i)*((po2(2))/(1.2*length(handles.mrilabel))) po2(3) po2(4)],'string','','fontsize',12,...
       'tag',handles.mrilabel{i});
end
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
function varargout = relabel_tdt_OutputFcn(hObject, eventdata, handles) 
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
handles.newlabels=get(handles.listbox1,'string');
handles.output = handles.newlabels;
guidata(hObject, handles);
uiresume;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
uiresume;


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
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selection = get(hObject,'value');
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

function  pb_call(hObject, eventdata, handles)
groupname = get(hObject,'string');
list = get(handles.listbox1,'string');
handles.selection = get(handles.listbox1,'value');
rename = cell(length(handles.selection),1);
for i = 1:length(handles.selection)
    rename{i} = string(strcat(groupname, num2str(i)));
end
list(handles.selection) = rename;
set(handles.listbox1,'string',list);
txth = findobj('tag',groupname{1});
txt = sprintf('Chan %s',num2str(handles.selection));
set(txth,'string',txt,'fontname','optima');
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
