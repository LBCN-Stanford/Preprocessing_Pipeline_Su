function [zCCEP,cond,onsetind, group] = LBCN_ccep(dataMat,chanLabel,stimchan,pathchan,thr,dcchan, plotchan,show_ost,currpath)
%   Compute CCEP
%   Inputs -  
%       dataMat:    bipolar data matrix in columes
%       chanLabel:  bipolar channel labels
%       stimChan:   channel index being stimulated in the current file.
%                   Optional.
%       pathchan:   pathological channel index. Optional. For data with
%                   fewer stimulated channels recorded (like Stanford cohort),
%                   better leave it empty.
%       thr:        threshold for initial auto detection of the pulse onset. 
%                   Optional. Default 4*std. When the resulting detection is
%                   showing a lot of false negatives (missed pulses), may
%                   consider decrease this threshold. 
%       dcchan:     DC channel showing pulse onsets (currently only for
%                   China cohort). Optional.
%       plotchan:   channels to plot. Optional. Default all channels. 
%       show_ost:   whether to show the detected pulse onset in an
%                   interface for manual correctoin. Default 1.
%       currpath:   directory of saved files.
%       There are couple of other parameters that will change detection
%       results. will have a separate scipt to load all initial default
%       parameters, and the user can change parameters from there. 
%   Outputs -  
%       zCCEP:      epoched and baseline corrected CCEP data in
%       {channel}{stimulation group} structure.
%       cond:       channel(s) being stimulated in the current file.
%       onsetind:   pulse onset time stamps. 
%       group:      start and end of each group of pulses. 
%   -----------------------------------------
%   =^._.^=     Su Liu
%
%   suliu@standord.edu
%   -----------------------------------------
fs = 1000;
if nargin<2 || isempty(chanLabel)
    chanind = 1:size(dataMat,2);
    chanLabel = num2str(chanind);
    chanLabel = strsplit(chanLabel);
end
if nargin<3 || isempty(stimchan)
    varall = var(dataMat);
    stimchan = find(varall > 50*median(varall));
    if find(diff(stimchan) ~=1 ) == 1
        stimchan(diff(stimchan)~=1) = [];
    else
        stimchan(find(diff(stimchan,2) ~= 0) + 2) = [];
    end
end
if nargin < 4 || isempty(pathchan)
    pathchan = [];
end
if nargin < 5 || isempty(thr)
    thr = 3.5;
end
if nargin < 6 || isempty(dcchan)
    onsetind = [];
else
    diod = dcchan/max(dcchan);
    tmp = zeros(length(diod),1);
    tmp(diod>0.3) = 1;
    xx = diff(tmp);
    onsetind = find(xx==1); 
end

if nargin < 7 || isempty(plotchan)
    %plotchan = stimchan;            
    plotchan = 1:length(chanLabel); % default: plot all channels
end
if nargin < 8 || isempty(show_ost)
    show_ost = 1;
end
if nargin < 9 
    currpath = [];
end

dm = dataMat(:,stimchan);
chan = chanLabel(stimchan);
disp('Channels being used for onset detection:')
disp('');
disp(chan(:))
%null = nan(size(dm));
%ind = [];
index = [];
b = fir1(64,[0.5 200]/(fs/2));    % filter for onset detection
a = 1;
bb = fir1(64,[1 50]/(fs/2));      % filter for computing CCEPs
aa = 1;
df = filtfilt(bb,aa,dm);
df2 = filtfilt(b,a,dm);
dif2 = diff(df2,2);
if isempty(onsetind)
    %% First to detect pulse onset
    disp(' ');
    disp('Finding stim onsets');
    for i =1:size(dm,2)
        clear alligned
        clear allignedIndex
        clear timeDiff
        if ismember(i+stimchan(1)-1,pathchan)   %Skip the current channel for onset detection if it is pathological. 
            tx = strcat('skip',chan(i));
            disp(tx);
            continue
        end
        adif2 = abs(dif2(:,i));
        ind = find(adif2 > thr*std(abs(dif2(:,i))));% Initial detection of signal jumps
        ind = ind+3;
        onset = find(diff(ind) > 0.3*fs);                     
        onset = [1;onset];
        onsetind = ind(onset+1);
        [hh, yy] = hist(diff(onsetind),0.2*fs);     % Find the inter-pulse interval
        [~,in] = max(hh(2:end));
        interv = yy(in+2-1);        
        keep = find(diff(onsetind) > (interv - round(20*fs/1000)));% Keep most of the time-locked events
        other = onsetind(diff(onsetind) < (interv - round(20*fs/1000)));
        onsetind2 = onsetind(keep + 1);
        fdis = find(diff(onsetind2) > 1.5*median(diff(onsetind2)));
        other = [other;onsetind2(fdis+1)];          
        onsetind2(fdis+1) = [];
        if length(other) > 250                      % If there are many spontaneous events detected (possibly spikes), skip this channel for onset detection
            tx = strcat('skip',chan(i));
            disp(tx);
            continue;
        end
        [allignedAll,~,~] = getaligneddata(df2(:,i),onsetind,round([-5 20]*fs/1000));% Generate an artifact template 
        [alligned,~,~] = getaligneddata(df2(:,i),onsetind2,round([-5 20]*fs/1000));
        alligned = squeeze(alligned);               
        alligned=data_norm(alligned,2);
        template = squeeze(mean(detrend(alligned,'constant'),2));
        for k = 1:size(alligned,2)
            %alligned(:,k) = detrend(alligned(:,k),'constant');
            [acor(:,k),~] = xcorr(template,alligned(:,k),round(5*fs/1000));
            [maxcorr,~] = max(abs(acor(:,k)));
            if max(acor(:,k)) ~= maxcorr
                alligned(:,k) = -alligned(:,k);
            end
            %timeDiff(k) = lag(I)
        end
        template = squeeze(mean(alligned,2));
        alligned = squeeze(allignedAll);
        alligned=data_norm(alligned,2);
        discard = [];
        for k = 1:size(alligned,2)
            [acor(:,k),lag] = xcorr(template,alligned(:,k),round(5*fs/1000));
            [maxcorr,~] = max(abs(acor(:,k)));
            if maxcorr < 0.2
                discard = [discard k];
                continue;
            else
                %timeDiff(k) = lag(I);
            end
        end
        onsetind(discard) = [];
        index = [index;onsetind];
        index = sort(index);
        onsetall=find(diff(index) > 0.4*fs);
    end
    
    onsetind = index(onsetall+1);
    
    %% Do a quick clustering if there are >30 possible false detections
    try
        if length(other) > 30
            [epoched,ts,~] = getaligneddata(dm(:,1), onsetind ,round([-150 150]*fs/1000));
            epoched = squeeze(epoched);
            [b,a] = butter(2,[80 400]/(fs/2));
            sig(:,1,:) = epoched;
            sig(:,2,:) = filtfilt(b,a,epoched);
            sig(:,3,:) = ts';
            [feature_matrix,~,discard] = calculate_feature_ccep(sig,fs);
            [L,C] = kmeans_PR(feature_matrix(:,[1 2 9])',2);
            [~,sc] = min(C(1,:));hfoind = onsetind(~discard);hfoind = hfoind(L == sc);
            [~,hfoindex] = intersect(onsetind,hfoind);onsetind(hfoindex) = [];
        end
    catch
    end
    %% end
end
last = [find(diff(onsetind) > 3*median(diff(onsetind)));length(onsetind)]; % Separate pulses in different groups. Only useful for China cohort
first = [1;last+1];
first(end) = [];
group = [first last];
atfind = (last - first) <= 2;
%group(atfind,:) = []; 
try
    onsetind(group(atfind,1):group(atfind,2)) = [];
catch
end
%group(atfind,:) = [];          
group(:,2) = group(:,2)-1;
if size(group,1) >3
    onsetind(group(1:end-1,2)+1) = nan;
    %group(2:end,1) = group(2:end,1)-1;
end
cond = cell(size(group,1),1);
if show_ost
    onsetind = checkOnset(df2,onsetind,group,chanLabel,chan);
    last = [find(diff(onsetind) > 3*median(diff(onsetind)));length(onsetind)]; % Separate pulses in different groups. Only useful for China cohort
    first = [1;last+1];
    first(end) = [];
    group = [first last];
    group(:,2) = group(:,2)-1;
    cond = cell(size(group,1),1);
%     null = nan(size(dif2,1),1);
%     null(onsetind(1:end-1)) = 1;
%     figure;
%     stem(null)
%     hold on
%     plot(df(:,1));
%     pause;
%     close
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Epoch and compute CCEP
ep1 = round(-0.2 * fs);
ep2 = round(fs);
dl = ep2-ep1;
check_lag = round(20*fs/1000);
disp(' ');
disp('Epoching');
%orig=nan(check_lag*2+dl,1);
df3 = filtfilt(bb,aa,dataMat);
j = 1;
for i = stimchan
    %for j = 1:size(group,1)
    try
        currind = onsetind(group(j,1):group(j,2));
        window1 = true(size(dm,1),1);
        window1(currind(1):currind(end)) = false; % outside the current stimulation window
        window2 = false(size(dm,1),1);
        window2((currind(1)+10*fs):(currind(end)-2*fs)) = true;% 10s:end-2s within the current stimulation window
        if (nanmax(abs(df3(window2,i))) < 0.1 ...       % See if current channel is the stim chan: 1. flat signal after 10 seconds? 2. Huge variance?
                || nanvar(abs(df3(window2,i))) < 0.1*nanvar(abs(df3(window1,i))))...
                && isempty(cond{j}) ...
                cond{j} = strcat('stim ',chanLabel{i});
        end
        j = j+1;
    catch
        continue;
    end
    % end
end
for i =1:size(df3,2)
    for j = 1:size(group,1)
            clear alligned
            clear allignedIndex
            clear timeDiff
            clear acor
            clear timediff
            clear lag
        currind = onsetind(group(j,1):group(j,2));
        [alligned,~,~] = getaligneddata(df3(:,i), currind ,round([-200 1000]*fs/1000));
        alligned = squeeze(alligned);%all epoched CCEP of current shaft
        alligned=data_norm(alligned,2);
        template = squeeze(mean(alligned,2));
        alli = nan(check_lag*2+dl,size(alligned,2));
        n = 1;
        ns = [];
        for k = 1:size(alligned,2)
            [acor(:,k),lag] = xcorr(alligned(:,k),template,round(20*fs/1000));
            [maxcorr,I] = max(abs(acor(:,k)));
            if max(abs(alligned(:,k))) > 500
                ns = [ns k];
                alli(check_lag:check_lag+dl,k) = nan(size(alligned(:,k)));
                %continue;
%             elseif maxcorr < 0.3
%                 ns = [ns k];
%                 %alli(check_lag:check_lag+dl,k)=nan(size(alligned(:,k)));
%                 alli(check_lag:check_lag+dl,k) = alligned(:,k);
%                 %continue;
            else
                timeDiff = lag(I);
                if abs(timeDiff) == round(20*fs/1000)
                    ns = [ns k];
                    alli(check_lag:check_lag+dl,k) = alligned(:,k);
                    %alli(check_lag:check_lag+dl,k)=nan(size(alligned(:,k)));
                    %continue;
                else
                    if max(acor(:,k)) == max(abs(acor(:,k)))
                        alli(check_lag-timeDiff:check_lag+dl-timeDiff,k) = alligned(:,k);
                    else
                        alli(check_lag-timeDiff:check_lag+dl-timeDiff,k) = alligned(:,k);
                    end
                    n=n+1;
                end
            end
        end
        signal = alli(check_lag:check_lag+dl,:);
        nv2=nanvar(signal(:,:));
        bad2= (nv2>=10*median(nv2));
        bad2=logical(bad2+(nanmax(abs(signal))>= 100));
        signal(:,bad2) = nan;
        atf{i}{j} = bad2;
        CCEP{i}{j}(1,1,:,:) = signal;
        zCCEP{i}{j} = baseline_norm(CCEP{i}{j}, 1:size(CCEP{i}{j},3), 1:round(180*fs/1000), 'z',bad2);
    end
end
if length(plotchan) >= 10 % try ploting signal by groups
        n=1;
        grpplot1(n) = 1;
        grpplot2(n) = 1;
        for i = 2:size(df3,2)
            CN = cellstr((join(regexp(string(chanLabel{i}),'[A-Z]','Match','ignorecase'),'')));
            CNp = cellstr((join(regexp(string(chanLabel{i-1}),'[A-Z]','Match','ignorecase'),'')));
        
            if strcmp(CN, CNp)
                grpplot2(n) = grpplot2(n) +1;
                continue;
            else
                NAME = strsplit(chanLabel{i-1},'-');
                groupname(n) = cellstr((join(regexp(string(NAME{1}),'[A-Z]','Match','ignorecase'),'')));
                n = n+1;
                grpplot1(n) = grpplot2(n-1)+1;
                grpplot2(n) = grpplot1(n);
            end
        end
        for k = 1:length(grpplot1)
            try
            plotchan = grpplot1(k):grpplot2(k);
                plot_CCEP
                print(gcf, fullfile(currpath,strcat('CCEP_',groupname{k})),'-opengl','-r300','-dpng');
                close;
            catch
                continue;
            end
        end
else
    plot_CCEP
    print(gcf, fullfile(currpath,'result','CCEP_All'),'-opengl','-r300','-dpng');
    close;
end
    
