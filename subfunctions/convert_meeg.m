function convert_meeg(zccep,cond,onset, group,D)

for k = 1:length(cond)
    for n = 1:length(zccep)
        DD(n,:,:) = (zccep{n}{k});
    end
    events.categories(k).name = cond{k};
    events.categories(k).categNum = k;
    events.categories(k).numEvents = size(zccep{n}{k},2);
    events.categories(k).start = [onset(group(k,1):group(k,2))']/D.fsample;
    events.categories(k).duration = nan(size(zccep{n}{k},2),1)';
    events.categories(k).stimNum = group(k,1):group(k,2);
end
evt = events;
indc = 1:length(evt.categories);
twepoch=[-200 1000];
bc = 0;
prefix = 'zCCEP_SPM_';
trl = [];
bctrl = [];
evtspm = [];
conditionlabels = [];
for i = 1:length(indc)
    nevc = getfield(evt.categories(indc(i)),'start');
    if isempty(nevc) % No information for this category
        continue
    end
    aa = evt.categories(indc(i));
    tempevt = struct('type',repmat({aa.name},1,aa.numEvents),...
        'value',num2cell(aa.stimNum),...
        'time',num2cell(aa.start),...
        'duration',num2cell(aa.duration),...
        'offset',repmat({0},1,aa.numEvents));
    evtspm = [evtspm , tempevt];
    conditionlabels = [conditionlabels; repmat({aa.name}, length(nevc),1)];
    for j = 1:length(nevc)
        ons = indsample(D,nevc(j) + (twepoch(1)/1000));
        off = ons + diff(twepoch)/1000*fsample(D);
        %off = indsample(D,nevc(j) + (twepoch(2)/1000));
        trl = [trl; [ons, off]];
        if bc && isnumeric(twbc)
            bc1 = indsample(D,nebc(j)+(twbc(1)/1000));
            bc2 = indsample(D,nebc(j)+(twbc(2)/1000));
            bctrl = [bctrl; [bc1, bc2]];
            bctrl_id = 1:length(conditionlabels);
        end
    end
end
inbounds = (trl(:,1)>=1 & trl(:, 2)<=D.nsamples);
timeOns = aa.start;%twepoch(1)/1000;
ntrial = size(trl, 1);
nsampl = unique(round(diff(trl, [], 2)))+1;
ev = D.events;
badchans = chanlabels(D,badchannels(D));
D = D.events(1,evtspm);
Dnew = clone(D, [prefix D.fname], [size(DD,1), nsampl(1), ntrial]);
isTF = 0;

Dnew = timeonset(Dnew, timeOns);
Dnew = type(Dnew, 'single');
Dnew = conditions(Dnew, ':', conditionlabels);
Dnew = trialonset(Dnew, ':', trl(:, 1)./D.fsample+D.trialonset);
Dnew = badtrials(Dnew,[],1);
Dnew = condlist(Dnew,conditionlabels);
D = meeg(Dnew);
save(D);

evtspm = [];
ncat = length(evt.categories);
names = cell(1,ncat);
onsets = cell(1,ncat);
durations = cell(1,ncat);
for i = 1:ncat
    aa = evt.categories(i);
    if ~isempty(aa.name)
        if isempty(aa.stimNum)
            aa.stimNum = 1:aa.numEvents;
        end
        tempevt = struct('type',repmat({aa.name},1,aa.numEvents),...
            'value',num2cell(aa.stimNum),...
            'time',num2cell(aa.start),...
            'duration',num2cell(aa.duration),...
            'offset',repmat({0},1,aa.numEvents));
        evtspm = [evtspm , tempevt];
        names{i} = aa.name;
        onsets{i} = [aa.start];
        durations{i} = [aa.duration];
    end
end
%save events in SPM friendly format
[~,fname] = fileparts(D.fname);
save([path(D),'onset_',fname,'.mat'],'names','durations','onsets')

%Create and save MEEG object


