function p =  task_config(task)

switch lower(task)
    case 'mmr'
        p.fieldepoch = 'start';
        p.twepoch = [-300 2200]; %Max of RTs as default
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
        p.plot_cond = 1:8;
end


confn = fieldnames(p);
for i = 1:length(confn)
    val = getfield(p,confn{i});
    assignin('caller',confn{i},val);
end
