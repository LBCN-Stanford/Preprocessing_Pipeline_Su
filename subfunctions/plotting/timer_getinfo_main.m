function out = timer_getinfo_main(task,sbj)
S.fh = figure('units','pixels',...
              'position',[1000 600 230 200],...
              'menubar','none',...
              'name','Data Information',...
              'numbertitle','off',...
              'resize','off');
S.tx = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[160 35 30 30],...
                 'fontsize',14,...
                 'string','5','FontName','Optima');
             in = sprintf('%s\n\n\n%s\n\n\n%s','Task name identified:','Subject ID identified: ');
S.tx2 = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[7 100 200 80],...
                 'fontsize',14,...
                 'string',in,'FontName','Optima');
             
             S.input = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[15 85 180 20],...
                 'fontsize',14,...
                 'string',sbj,'FontName','Optima','enable','off');
             dynamic_list;
             currtask = find(strcmpi(task,tasklist));
             if isempty(currtask)
                 currtask = 9;
             end
             S.input2 = uicontrol('style','popup',...
                 'unit','pix',...
                 'position',[15 30 180 20],...
                 'fontsize',14,...
                 'string',tasklist,...
                 'FontName','Optima','enable','off','value',currtask);
out.task=task;
out.sname=sbj;             
setappdata(S.fh,'out',out);             
             S.tmr = timer('Name','Countdown',...
                 'Period',1,...  % 10 minute snooze time.
              'StartDelay',.01,... 
              'ExecutionMode','fixedSpacing',...
              'StopFcn',@deleter);   % Function def. below.
S.pb = uicontrol('style','push',...
                 'units','pix',...
                 'position',[10 50 150 30],...
                 'fontsize',14,...
                 'string','Click to change','FontName','Optima',...
                 'callback',{@pb_call,S});
set(S.tmr,'TimerFcn',{@update_disp,S});     
set(S.tmr,'TasksToExecute',str2double(get(S.tx,'string'))) ; 
if ~isempty(out.task) && ~isempty(out.sname)
    start(S.tmr);
    waitfor(S.fh,'name');
   
    %close(S.fh);
else
    pb_call(S.pb,[],S);
    waitfor(S.fh,'name');
    %close(S.fh);
end
out = getappdata(S.fh,'out');
delete(S.fh);

function pb_call(varargin)
% Callback for pushbutton, deletes one line from listbox.

S = varargin{3};
obj = varargin{1};
stop(S.tmr);
set(S.input,'enable','on');
set(S.input2,'enable','on');
set(S.tx,'string','');
set(obj,'string','Done','FontName','Optima',...
    'callback',{@pb_call2,S},'position',[30 10 150 30]);

S.def = uicontrol('style','push',...
    'units','pix',...
    'position',[30 120 150 30],...
    'fontsize',14,...
    'string','Use default','FontName','Optima',...
    'callback',{@pbdef_call,S});

S.edit = uicontrol('style','push',...
    'units','pix',...
    'position',[30 160 150 30],...
    'fontsize',14,...
    'string','Add task','FontName','Optima',...
    'callback',{@pbedit_call,S});
set(S.tx,'String','Subject','position',[13 92 80 20]);
set(S.tx2,'String','Task','position',[10 52 80 20]);
set(S.input,'Position',[83 90 100 20]);
set(S.input2,'Position',[80 48 110 30]);


% Need to check string!
% set(S.tmr,'TasksToExecute',str2double(get(S.tx,'string')))  
% start(S.tmr);
function [] = update_disp(varargin)
S = varargin{3};
N = str2double(get(S.tx,'string'));
set(S.tx,'string',num2str(N-1));
if N == 1
    set(S.fh,'name','Closing');
    %close(S.fh);
end
function deleter(obj,edata)   %#ok   M-Lint doesn't know the callback fmt.
% Callback for stopfcn.
wait(obj);
delete(obj);

function out = pb_call2(varargin)
S = varargin{3};
list = get(S.input2,'string');

out.task=list{get(S.input2,'value')};
out.sname=get(S.input,'string');
if isempty(out.sname)
    out.sname = 'SXX_';
end
setappdata(S.fh,'out',out);
set(S.fh,'name','Closing');
%close(S.fh);

function out = pbdef_call(varargin)
S = varargin{3};
out.task='other';
set(S.input,'string','SXX_');
try
    out.sname=get(S.input,'string');
catch
    out.sname='SXX_';
end
pause(0.8);
setappdata(S.fh,'out',out);
set(S.fh,'name','Closing');

function out = pbedit_call(varargin)
S = varargin{3};
%out.task='other';
try
    out.sname=get(S.input,'string');
    if isempty(out.sname)
        out.sname='XX_XXX_';
    end
catch
    out.sname='XX_XXX_';
end
prompt = {'\fontsize{16} \fontname{Optima} Task name','\fontsize{16} \fontname{Optima} Epoch window','\fontsize{16} \fontname{Optima} Baseline window',...
              '\fontsize{16} \fontname{Optima} Number of conditions','\fontsize{16} \fontname{Optima} Skip before','\fontsize{16} \fontname{Optima} Skip after','\fontsize{16} \fontname{Optima} Condition names'};
title = 'Define Task';
dims = [2 35];
definput = {'MyNewTask','-300 1000','-300 0','4','12','0','Cond1 Cond2 Cond3 Cond4'};
    options.WindowStyle='normal';
    options.Interpreter='tex';
    
inputwin =  inputdlg(prompt,title,dims,definput,options);
[task,~] = define_new_task(inputwin);        
out.task = task;
setappdata(S.fh,'out',out);
set(S.fh,'name','Closing');