function p =  task_config(task)

switch lower(task)
case 'mmr'
p.fieldepoch = 'start';
p.twepoch = [-400 4200]; %Max of RTs as default
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-150 0];
p.twResc = [-150 0];
p.smoothwin = 100;
p.twsmooth = [-150 2000];
p.plot_cond = [];
case 'vtcloc'
p.fieldepoch = 'start';
p.twepoch = [-300 500];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-100 400];
p.plot_cond = [];
case 'animal'
p.fieldepoch = 'start';
p.twepoch = [-200 700];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-100 0];
p.twsmooth = [-100 600];
p.plot_cond = [];
case 'category'
p.fieldepoch = 'start';
p.twepoch = [-300 850];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 800];
p.plot_cond = {'subcat'};
case 'other'
p.fieldepoch = 'start';
p.twepoch = [-200 1200];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 800];
p.plot_cond = [];
case 'emotionf'
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 800];
p.plot_cond = 1:3;
case 'race_cat'
p.fieldepoch = 'start';
p.twepoch = [-300 1100];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 800];
p.plot_cond = [];
case 'emotiona'
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 800];
p.plot_cond = [1 2 3 4 5 6];

case  'ictalmemrecall'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-200 900];
p.plot_cond = [1 2 3 4 5 6];

case  'ictalmemrecallnew'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-250 950];
p.plot_cond = [1 2 3 4 5];

case  'ictalcogtaskold'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 900];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-250 850];
p.plot_cond = [1 2];

case  'sponmem'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-300 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-250 950];
p.plot_cond = [1 2 3];

case  'ictalcogbaselinecombined'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-300 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-250 950];
p.plot_cond = [1 2];

case  'ictalcogrecallcombined'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-300 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-250 950];
p.plot_cond = [1 2 3 4];

case  'ictalcogmem2'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-300 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-250 950];
case  'emotiona_facelock'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-1500 700];
p.bc = 1;
p.bcfield = 'start';
p.twbc = cell(1, 3);
p.twbc{1} = 'ITI';
p.twbc{2} = '700';
p.twbc{3} = '1000';
p.smoothwin = 50;
p.twResc = cell(1, 3);
p.twResc{1} = 'ITI';
p.twResc{2} = '700';
p.twResc{3} = '1000';
p.twsmooth = [-1450 650];
p.plot_cond = [1 2 3 4 5 6 7 8];
case  'emotionf_newbl'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = cell(1, 3);
p.twbc{1} = 'ITI';
p.twbc{2} = '700';
p.twbc{3} = '900';
p.smoothwin = 50;
p.twResc = cell(1, 3);
p.twResc{1} = 'ITI';
p.twResc{2} = '700';
p.twResc{3} = '900';
p.twsmooth = [-250 950];
p.plot_cond = [1 2 3 4 5];

case  'forpaper'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-450 850];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-400 800];
p.plot_cond = [1 2 3 4 5 6];

case  'forpaper2'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-450 850];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-400 800];
p.plot_cond = [1 2 3];

case  'ictalcogencode'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-400 800];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-350 750];
p.plot_cond = [1 2 3];

case  'ictalcogencode'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-400 800];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-200 0];
p.smoothwin = 50;
p.twResc = [-200 0];
p.twsmooth = [-350 750];
p.plot_cond = [1 2 3];

case  'ictalcogbaseline'
p = struct;
p.fieldepoch = 'start';
p.twepoch = [-300 1000];
p.bc = 1;
p.bcfield = 'start';
p.twbc = [-300 0];
p.smoothwin = 50;
p.twResc = [-300 0];
p.twsmooth = [-250 950];
p.plot_cond = [1 2 3];


end

%p.bc = 0;
confn = fieldnames(p);
for i = 1:length(confn)
val = getfield(p,confn{i});
assignin('caller',confn{i},val);
end
