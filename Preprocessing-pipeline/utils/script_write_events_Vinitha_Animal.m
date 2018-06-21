function [events] = script_write_events_Vinitha_Animal(conds, onset,offset,list)

% Create events.mat in the form of Parvizi lab format for the VTC localizer
% based on the condition number, onset and offset of each event, and the
% list of categories.

ncond = max(conds);
events = struct();
if nargin<4
    list = {'animal_F','animal_NF','bird_F','bird_NF','fish_F','fish_NF',...
        'human_F','human_NF','object','place','limbs'};
end
for i = 1:ncond
    events.categories(i) = struct('name',[],'categNum',[],'numEvents',[],...
        'start',[],'duration',[],'stimNum',[],'wlist',[],'RT',[],...
        'sbj_resp',[],'correct',[],'nextCategory',[]);
    events.categories(i).name = list{i};
    events.categories(i).categNum = i;
end

for i=1:length(onset)
    ic = conds(i);
    events.categories(ic).start = [events.categories(ic).start, onset(i)];
    events.categories(ic).RT = [events.categories(ic).RT, offset(i)];
    events.categories(ic).duration = [events.categories(ic).duration,...
        offset(i)-onset(i)];
    events.categories(ic).stimNum = [events.categories(ic).stimNum, i];
end

for ic = 1:ncond
    events.categories(ic).numEvents = length(events.categories(ic).start);
end

save('Events_Parvizilab_Animals.mat','events')
    