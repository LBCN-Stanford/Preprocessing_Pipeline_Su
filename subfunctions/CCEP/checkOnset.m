function varargout = checkOnset(varargin)
% CHECKONSET MATLAB code for checkOnset.fig
%      CHECKONSET, by itself, creates a new CHECKONSET or raises the existing
%      singleton*.
%
%      H = CHECKONSET returns the handle to a new CHECKONSET or the handle to
%      the existing singleton*.
%
%      CHECKONSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKONSET.M with the given input arguments.
%
%      CHECKONSET('Property','Value',...) creates a new CHECKONSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before checkOnset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to checkOnset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checkOnset

% Last Modified by GUIDE v2.5 04-Feb-2019 10:06:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkOnset_OpeningFcn, ...
                   'gui_OutputFcn',  @checkOnset_OutputFcn, ...
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


% --- Executes just before checkOnset is made visible.
function checkOnset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to checkOnset (see VARARGIN)
[b,a] = butter(2,[2,50]/500);
handles.removed = [];
handles.data = filtfilt(b,a,varargin{1});
handles.onset = varargin{2};
handles.group = varargin{3};
handles.chanLabel = varargin{4};
handles.chan = varargin{5};
null = nan(size(handles.data,1),1);
null(handles.onset(~isnan(handles.onset))) = 1;
handles.axes1;
handles.onsetplot = stem(null,'color',[0.4 0.4 0.4],'marker','.','markersize',8);
hold on
handles.dataplot = plot(1:length(null),handles.data(:,1),'color',[0.85 0.33 0.1],'linewidth',1);
% for n = 1:size(handles.group,1)
%     try
%         handles.labelplot(n) = text(handles.onset(handles.group(n,1))+5000,-0.1,handles.chan(n));
%     catch
%         continue
%     end
% end
currentind=[1 size(handles.data,1)];
    handles.axes1;
    handles.xlimit = [currentind(1) currentind(2)];
set(handles.popupmenu1,'string',handles.chan);
stimchanlabel = ['All' handles.chan];
set(handles.popupmenu2,'string',stimchanlabel);
set(gca,'ticklength',[0.001 0.001],'fontsize',16);
xlim([0 length(null)]);
xlabel('Timestamps');
hold off
% Choose default command line output for checkOnset
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

 
uiwait;%makes checkOnset wait for user response (see UIRESUME)


% --- Outputs from this function are returned to the command line.
function varargout = checkOnset_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
handles.onset(isnan(handles.onset))=[];

varargout{1} = handles.onset;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%set(handles.figure1,'WindowButtonDownFcn',[]);
    [~,xd,~]=select3('selectionMode','closest','pt',15,'Axes',handles.axes1);
    %try
    n=1;
 for k = 1:length(xd)
     try
        x(n) = xd{k};
        n = n+1;
     catch
         continue;
     end
 end
  %xd =  xd(~isempty(xd));
  try
      %handles.remove = find(handles.onset == x);
      difference = handles.onset - x;
      closest = abs(difference) == min(abs(difference));
      handles.onset(closest) =nan;
  catch
      return;
  end
  null = nan(size(handles.data,1),1);
  null(handles.onset(~isnan(handles.onset))) = 1;
PH = handles.onsetplot;
handles.axes1; 
%hold on
delete(PH);
handles.onsetplot = stem(null,'color',[0.4 0.4 0.4],'marker','.','markersize',8);
hold on
handles.dataplot = plot(1:length(null),handles.data(:,1),'color',[0.85 0.33 0.1],'linewidth',1);
%set(handles.popupmenu1,'string',handles.chan);
%stimchanlabel = ['All' handles.chan];
%set(handles.popupmenu2,'string',stimchanlabel);
hold off
set(gca,'ticklength',[0.001 0.001],'fontsize',16);
xlim(handles.xlimit);
guidata(hObject, handles);
uiwait;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.figure1,'WindowButtonDownFcn',[]);
    [pl,xd,yd]=select3('selectionMode','rect','pt',3,'Axes',handles.axes1);
    dataseg=yd{1}; 
    dif2 = diff(dataseg,2); 
    adif2 = abs(dif2);
    ind = find(adif2 > 4*std(abs(dif2)));% Initial detection of signal jumps
    ind = ind+3;
    onset = find(diff(ind) > 300);
    onset = [1;onset];
    onsetind = ind(onset+1)+xd{1}(1);
    
    n=1;
    for i = 1:length(pl{2})
        indredo(n)=find(handles.onset==pl{2}(i));
        n=n+1;
    end
    handles.onset(indredo)=[];
    handles.onset=sort([handles.onset;onsetind]);
    last = [find(diff(onsetind) > 3*median(diff(onsetind)));length(onsetind)]; % Separate pulses in different groups. Only useful for China cohort
    first = [1;last+1];
    first(end) = [];
    group = [first last];
    atfind = (last - first) <= 3;
    group(atfind,:) = [];           % The index of first and last stim for each group of pulses
    group(:,2) = group(:,2)-1;
    handles.group = group;
 
    
    null = nan(size(handles.data,1),1);
    null(handles.onset(1:end-1)) = 1;
    handles.axes1;
    cla;
    handles.onsetplot = stem(null,'color',[0.4 0.4 0.4],'marker','.','markersize',8);
    hold on
    handles.dataplot = plot(1:length(null),handles.data(:,1),'color',[0.85 0.33 0.1],'linewidth',1);
    
    set(handles.popupmenu1,'string',handles.chan);
%stimchanlabel = ['All' handles.chan];
%set(handles.popupmenu2,'string',stimchanlabel);
    set(gca,'ticklength',[0.001 0.001],'fontsize',16);
    xlim(handles.xlimit);
    xlabel('Timestamps');
    hold off
    
    
    
%     n=1;
%  for k = 1:length(xd)
%      try
%         x(n) = xd{k};
%         n = n+1;
%      catch
%          continue;
%      end
%  end
%   %xd =  xd(~isempty(xd));
%   try
%       handles.remove = find(handles.onset == x);
%       handles.onset(handles.onset == x) =nan;
%   catch
%       return;
%   end
%   null = nan(size(handles.data,1),1);
%   null(~isnan(handles.onset(1:end))) = 1;
% PH = handles.onsetplot;
% handles.axes1; 
% %hold on
% delete(PH);
% handles.onsetplot = stem(null,'color',[0.4 0.4 0.4],'marker','.','markersize',8);
% hold on
% handles.dataplot = plot(1:length(null),handles.data(:,1),'color',[0.85 0.33 0.1],'linewidth',1);
% %set(handles.popupmenu1,'string',handles.chan);
% %stimchanlabel = ['All' handles.chan];
% %set(handles.popupmenu2,'string',stimchanlabel);
% hold off
% set(gca,'ticklength',[0.001 0.001],'fontsize',16);
% xlim(handles.xlimit);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotchan = get(hObject,'value');
% handles    structure with handles and user data (see GUIDATA)
handles.axes1;
handles.dataplot.YData = handles.data(:,plotchan);
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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currgroup = get(hObject,'Value');
if currgroup>1 && size(handles.group,1)>3
    currentind = handles.group(currgroup-1,:);
    handles.axes1;
    handles.xlimit = [handles.onset(currentind(1))-2000 handles.onset(currentind(2))+2000];
    xlim([handles.onset(currentind(1))-2000 handles.onset(currentind(2))+2000]);
elseif currgroup>1 && size(handles.group,1)<=3
    currentind = handles.group(1,:);
    handles.axes1;
    handles.xlimit = [handles.onset(currentind(1))-2000 handles.onset(currentind(2))+2000];
    xlim([handles.onset(currentind(1))-2000 handles.onset(currentind(2))+2000]);
else
    currentind=[1 size(handles.data,1)];
    handles.axes1;
    handles.xlimit = [currentind(1) currentind(2)];
    xlim([currentind(1) currentind(2)]);
end
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
