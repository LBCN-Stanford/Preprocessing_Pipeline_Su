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

% Last Modified by GUIDE v2.5 14-Aug-2018 17:24:14

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
set(handles.listbox1,'string',handles.mrilabel,'fontsize',12);
set(handles.text3,'string',handles.eeglabel{1});
set(handles.figure1,'name','Cannot correlate channel labels with image data')
po = get(handles.text3,'position');
po2 = get(handles.edit1,'position');
for i = 1:length(handles.eeglabel)
     
   uicontrol('unit','normalized','style','text','position',...
       [po(1)+0.01 0.1+(i)*((po(2))/(1.2*length(handles.eeglabel))) po(3) po(4)],...
       'string',handles.eeglabel(i),'fontname','optima','fontsize',12,...
       'HorizontalAlignment','left');
   handles.newedit(i) = uicontrol('unit','normalized','style','edit','position',...
       [po2(1)+0.01 0.1+(i)*((po2(2))/(1.2*length(handles.eeglabel))) po2(3) po2(4)],'string','','fontsize',12);
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
for i =length(handles.eeglabel):-1:1
    handles.newlabels{i}=get(handles.newedit(i),'string');
end
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
