function [task,p] = define_new_task(varargin)
varargin=varargin{1};
task = lower(varargin{1});


p.fieldepoch = 'start';
p.twepoch = str2num(varargin{2});
%p.twepoch = [-300 1100];
p.bc = 1;
p.bcfield = 'start';
p.twbc = str2num(varargin{3});
if isempty(p.twbc)
    try
        p.twbc = strsplit(varargin{3},{' ',':',','});
    catch
        p.twbc = varargin{3};
    end
end
%p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = p.twbc;
p.twsmooth = [p.twepoch(1)+50 p.twepoch(2)-50];
p.plot_cond = 1:str2num(varargin{4});

%p.plot_cond = [];
def.(task).skip_before = str2num(varargin{5});
def.(task).skip_after = str2num(varargin{6});
def.(task).thresh_dur = 0.01;
def.(task).listcond = strsplit(varargin{7});
currentfolder = pwd;
cd(fileparts(which(fullfile('HFB plot', 'subfunctions', 'plotting' , 'mytask.m'))));
matlab.io.saveVariablesToScript('mytask.m',{'task','p'});
matlab.io.saveVariablesToScript('mytaskP.m',{'def'});
edit_task_conf;
cd(currentfolder);
