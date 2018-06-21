function [evtfile] = LBCN_read_events_diod_sodata(D,sodata, task)

% Function to extract stimuli information based on the diod contained in
% the DCchans_filename.mat SPM MEEG object and on the behavioral file. The
% name of the task should also be provided to load the correct defaults (e.
% g. 'MMR' or 'VTCLoc').
% -------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford, 11/13/2015, based on LBCM code
%
% Updated by Su Liu, 2018. Automatically identifys the mismatched skip triggers, DC chans and mislabeled channels. 


%% Get inputs

if nargin <1 || isempty(D)
    fname = spm_select(1,'mat','Select DCchans SPM object for diod');
    D = load(fname);
end

if nargin<2 || isempty(sodata)
    sodata = spm_select(1,'mat','Select sodata file for task');
end

if nargin<3 || isempty(task)
    disp('No task provided, getting all defaults as empty')
end

try
    def = get_defaults_Parvizi;
    deftask = getfield(def,task);
catch
    warning('Task name provided is not in defaults');
    deftask = struct('skip_before',0,'skip_after',0,'thresh_dur',0,...
        'listcond',{});
end


%% Reading PsychData BAHAVIORAL DATA

K = load(sodata);
if isfield(deftask,'block') %this is for the race task; for different blocks (active/recall..), just edit the get_Parvizi_default file.
    for i = 1:length(K.theData)
        allconds{i} = K.theData(i).tasktype;
    end
    lsi = find(strcmpi(allconds,deftask.block));
else
    lsi = 1:length(K.theData);
end
SOT = zeros(1,length(lsi));
%sbj_resp = NaN*ones(1,lsi);
ind = 1;
for si = lsi
    try
        SOT(ind) = K.theData(si).flip.StimulusOnsetTime;
        try
            if iscell(K.theData(si).keys(1))
                temp_key = num2str(cell2mat(K.theData(si).keys(1)));
            else
                temp_key = K.theData(si).keys;
            end
            switch temp_key
                case 'DownArrow'
                    K.theData(si).keys ='2';
                case 'End'
                    K.theData(si).keys ='1';
            end
        catch
            temp_key = 'NaN';
        end
        if isfield(K,'stimInf') && isfield(K.stimInf,'name')
            stim_Name(ind) = K.stimInf(si).name;
            stim_List(ind) = K.stimInf(si).list;
        end
        if ~isnan(str2num(temp_key))
            sbj_resp(ind) = str2num(temp_key);
        else
            sbj_resp(ind) = NaN;
        end
    catch
        SOT(ind) = 0;
    end
    ind = ind + 1;
end
goodtrials = SOT>0;
SOT = SOT(goodtrials);
if isfield(K,'stimInf') && isfield(K.stimInf,'duration')
    dur = [K.stimInf(goodtrials).duration];
end
if isfield(K,'stimInf') && isfield(K.stimInf(1),'oneback')
    oneback = [K.stimInf(goodtrials).oneback];
    if length(oneback) ~= length(SOT)
        oneback = [0 oneback]; %add first empty
    end
    indback = find(oneback==1);
    oneback(indback-1)=2;
end


%% reading analog channel

%1st version works when diod is 0 to 5Volts, 2nd version works when it is DC channel
[evt] = get_events_diod(fullfile(D.path,D.fname), task, [], deftask.skip_before, deftask.skip_after, deftask.thresh_dur);
% [evt] = get_events_clin_diod(fullfile(D.path,D.fname),def.ichan,0.5, ...
%     deftask.thresh_dur,deftask.skip_before,deftask.skip_after);


stim_onset = [evt(:).onsets];
rsp_onset= [evt(:).offsets];
stim_dur = [evt(:).durations];

if strcmpi(task,'MMR') % Get rest in a specific category (not on diod)
    IpdioI= [stim_onset(2:end)-rsp_onset(1:end-1) 0];
    rest_ind= find(IpdioI>5 & IpdioI<5.3);
    rest_onset= rsp_onset(rest_ind);
    rest_offset= stim_onset(rest_ind+1);
    rest_dur= rest_offset - rest_onset;
    [C,IA,IB] = intersect(rest_offset,stim_onset);
    if length(IB)<length(rest_onset)
        error('check rest_onset')
    end
end

%Ploting to check marks
marks_stim= 1*ones(1,length(stim_onset));
marks_rsp= 1*ones(1,length(rsp_onset));
figure;
plot(D(def.ichan,:));
hold on
plot(stim_onset*D.fsample,marks_stim,'r*');hold on
plot(rsp_onset*D.fsample,marks_rsp,'g*');
path = D.path;
if ~exist([path,filesep,'figs'],'dir')
    mkdir(path,'figs');
end
[p,name] = spm_fileparts(D.fname);
%print('-opengl','-r300','-dpng',strcat([path,filesep,'figs',filesep,'Diod_events_',name]));

%% Comparing photodiod with behavioral data

% df_SOT= diff(SOT);
% df_stim_onset= diff(stim_onset);
% figure, plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
% df= df_SOT - df_stim_onset;
% print('-opengl','-r300','-dpng',strcat([path,filesep,'figs',filesep,'Comparison_Diod_Behav_Events_',name]));
%
% if ~all(abs(df)<.1)
%     disp('behavioral data and photodiod mismatch')
%     find(abs(df)>.1)
%     return
% end
SOT0 = SOT-SOT(1);
stim_onset0 = stim_onset-stim_onset(1);
insn = [];
while 1
    try
        onsetDiff = SOT0-[stim_onset0 zeros(1,length(SOT0)-length(stim_onset0))];
    catch
        warning('Wrong number of skipped pulses: %d, correcting... ',deftask.skip_before);
        deftask.skip_before = find_skip(D(def.ichan,:),deftask.thresh_dur,D.fsample);
        [evt] = get_events_diod(fullfile(D.path,D.fname), task, [], deftask.skip_before, deftask.skip_after, deftask.thresh_dur);
        stim_onset = [evt(:).onsets];
        rsp_onset= [evt(:).offsets];
        stim_dur = [evt(:).durations];
        
        if strcmpi(task,'MMR') % Get rest in a specific category (not on diod)
            IpdioI= [stim_onset(2:end)-rsp_onset(1:end-1) 0];
            rest_ind= find(IpdioI>5 & IpdioI<5.3);
            rest_onset= rsp_onset(rest_ind);
            rest_offset= stim_onset(rest_ind+1);
            rest_dur= rest_offset - rest_onset;
            [C,IA,IB] = intersect(rest_offset,stim_onset);
            if length(IB)<length(rest_onset)
                error('check rest_onset')
            end
        end
        marks_stim= 1*ones(1,length(stim_onset));
        marks_rsp= 1*ones(1,length(rsp_onset));
        close gcf
        figure;
        plot(D(def.ichan,:));
        hold on
        plot(stim_onset*D.fsample,marks_stim,'r*');hold on
        plot(rsp_onset*D.fsample,marks_rsp,'g*');
        path = D.path;
        if ~exist([path,filesep,'figs'],'dir')
            mkdir(path,'figs');
        end
        [p,name] = spm_fileparts(D.fname);
        SOT0 = SOT-SOT(1);
        stim_onset0 = stim_onset-stim_onset(1);
        insn = [];
        while 1
            onsetDiff = SOT0-[stim_onset0 zeros(1,length(SOT0)-length(stim_onset0))];
            onsetMiss = find(abs(onsetDiff)>0.1);
            if onsetMiss
                insn = [insn onsetMiss(1)];
                stim_onset0 = insertX(stim_onset0,onsetMiss(1),SOT0(onsetMiss(1)));
            else
                warning('New skipped pulses for current data: %d, will continue. ',deftask.skip_before);
                break
            end
        end
        break;
    end
    onsetMiss = find(abs(onsetDiff)>0.1);  %%%%%%%%%%%
    if onsetMiss
        insn = [insn onsetMiss(1)];
        stim_onset0 = insertX(stim_onset0,onsetMiss(1),SOT0(onsetMiss(1)));
    else
        break
    end
end


% insn = [90 183 281];
if insn
    insn
    for i = 1:length(insn)
        ins_pul(i) = SOT(insn(i))-SOT(1)+stim_onset(1);
        ins_dur(i) = stim_dur(1);
    end
    stim_onset = insertX(stim_onset,insn,ins_pul);
    stim_dur = insertX(stim_dur,insn,ins_dur);
end
inst = 0;
for i = 1:length(SOT)
    if ismember(i,insn)
        inst = inst+1;
        stim_onset_new(i) = ins_pul(inst);
        stim_dur_new(i) = ins_dur(inst);
    else
        stim_onset_new(i) = stim_onset(i-inst);
        stim_dur_new(i) = stim_dur(i-inst);
    end
end
stim_onset = stim_onset_new;
stim_dur = stim_dur_new;
%%


df_SOT = diff(SOT);

df_stim_onset= diff(stim_onset);
save('test','SOT','stim_onset')

figure, plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
save('test','df_SOT','df_stim_onset');
df= df_SOT - df_stim_onset;
print('-opengl','-r300','-dpng',strcat([path,filesep,'figs',filesep,'Comparison_Diod_Behav_Events_',name]));


if ~all(abs(df)<.1)
    disp('behavioral data and photodiod mismatch')
    er = find(abs(df)>.1);
er=er(1)-1;
goodtrials(er)=0;
stim_onset(er)=[];
    %return
end


%% events and categories from psychtoolbox information
switch task
    case 'MMR'
        wlist= K.wlist;
        cond= [K.conds]';
        rt= NaN*ones(1,length(K.theData));
        for ii=1:length(K.theData)
            temp_rt = K.theData(ii).RT(1);
            rt(ii)= temp_rt;
        end
        
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            if  ci==6 % get rest in as it is not saved in SODATA
                events.categories(ci).name= sprintf('%s',categNames{ci});
                events.categories(ci).categNum= ci;
                events.categories(ci).numEvents= sum(length(rest_onset));
                events.categories(ci).start= rest_onset + 0.2;
                events.categories(ci).duration= rest_dur - 0.2;
                events.categories(ci).wlist= {'+'};
                events.categories(ci).RT=[];
                events.categories(ci).RTons=rest_onset + rest_dur;
                events.categories(ci).subcat=[];
                events.categories(ci).stimNum= max(stimNum)+1:max(stimNum)+length(rest_onset);
                
            else
                events.categories(ci).name= sprintf('%s',categNames{ci});
                events.categories(ci).categNum= ci;
                events.categories(ci).numEvents= sum(cond==ci);
                events.categories(ci).start= stim_onset(find(cond==ci));
                events.categories(ci).duration= stim_dur(find(cond==ci));
                events.categories(ci).stimNum= stimNum(find(cond==ci));
                events.categories(ci).wlist= wlist(find(cond==ci));
                events.categories(ci).RT= rt(find(cond==ci));
                events.categories(ci).RTons=rt(find(cond==ci))+stim_onset(find(cond==ci));
                events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
                
                if strcmpi(task,'MMR') && ci==5
                    correct= NaN*ones(1,sum(cond==ci));
                    wlist_tmp= wlist(find(cond==ci));
                    for ii=1:length(wlist_tmp)
                        tmp = wlist_tmp(ii);
                        tmp2= tmp{1};
                        pl= regexp(tmp2,'+');
                        el= regexp(tmp2,'=');
                        if ( str2double(tmp2(1:(pl-1))) + str2double(tmp2((pl+1):(el-1))) == str2double(tmp2((el+1):end)))
                            correct(ii)=1;
                        else
                            correct(ii)=2;
                        end
                    end
                    events.categories(ci).correct= correct;
                    
                else
                    events.categories(ci).correct=[];
                end
            end
        end
    case 'VTCLoc'
        cond= [K.conds]';
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
        end
    case 'Animal'
        cond= [K.conds]';
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
        end
    case 'category'
        cond= [K.conds]';
        cond = cond(goodtrials);
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
            %
            try
                events.categories(ci).stimName = stim_Name(find(cond==ci));
                events.categories(ci).stimList = stim_List(find(cond==ci));
                events.categories(ci).dur = dur(find(cond==ci));
                events.categories(ci).oneback = oneback(find(cond==ci));
            catch
            end
            
        end
    case 'EmotionF'
        cond= [K.conds]';
        cond = cond(goodtrials);
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
            %
            try
                events.categories(ci).stimName = stim_Name(find(cond==ci));
                events.categories(ci).stimList = stim_List(find(cond==ci));
                events.categories(ci).dur = dur(find(cond==ci));
                events.categories(ci).oneback = oneback(find(cond==ci));
            catch
            end
            
        end
    case 'RACE_CAT'
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        for i=1:length(K.theData)
            allcondition{i}=K.theData(i).conds(1);
        end
        conds = allcondition(lsi);
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(strcmp(categNames{ci},conds));
            events.categories(ci).start= stim_onset(strcmp(categNames{ci},conds));
            events.categories(ci).duration= stim_dur(strcmp(categNames{ci},conds));
            events.categories(ci).stimNum= stimNum(strcmp(categNames{ci},conds));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(strcmp(categNames{ci},conds));
        end
    case 'other'
        cond= [K.conds]';
        cond = cond(goodtrials);
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            categNames = cellstr(num2str(unique(cond)'));
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
            %
            try
                events.categories(ci).stimName = stim_Name(find(cond==ci));
                events.categories(ci).stimList = stim_List(find(cond==ci));
                events.categories(ci).dur = dur(find(cond==ci));
                events.categories(ci).oneback = oneback(find(cond==ci));
            catch
            end
            
        end
        
end


%% Take out events with a NaN as start
for iii=1:length(categNames)
    deleteev=isnan(events.categories(iii).start);
    if any(deleteev)
        events.categories(iii).start(deleteev)=[];
        events.categories(iii).duration(deleteev)=[];
        events.categories(iii).stimNum(deleteev)=[];
        events.categories(iii).wlist(deleteev)=[];
        events.categories(iii).RT(deleteev)=[];
        events.categories(iii).RTons(deleteev)=[];
        events.categories(iii).sbj_resp(deleteev)=[];
        if iii==5 && strcmpi(task,'MMR')
            events.categories(iii).correct(deleteev)=[];
        end
    end
    
end


%% %% making a saving directory

evtfile = fullfile(D.path,['eventsSODATA_',D.fname]);
save(evtfile,'events');

