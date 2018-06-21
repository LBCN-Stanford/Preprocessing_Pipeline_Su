function [pathological_chan_id,pathological_event]=find_paChan(eeg,chanNames,fs,thr)
%   Find possible pathological channels with HFO and spikes.
%   Pathological (irritative) channels are defined as channels with event 
%   occuerrnce rate > [thr] times of the average HFO+spike rate
%   eeg:        miltichannel EEG data in columns.
%   chanNames:  channel labels.
%   fs:         sampling frequency.
%   tr:         threshold to define the patholgocial channels.
%   function returns the problematic channel index and indicies of trials
%   that overlaps with pathological events.
%   Su Liu
%   suliu@standord.edu

if nargin<4
    thr = 2;
end

z=1;
%Create bipolar for HFO and spike detection
fprintf('%s\n','---- Creating bipolar montage ----')
for i=1:size(eeg,2)-1
    name1 = join(regexp(string(chanNames{i}),'[a-z]','Match','ignorecase'),'');
    name2 = join(regexp(string(chanNames{i+1}),'[a-z]','Match','ignorecase'),'');
    if strcmp(name1,name2)
        eeg_bi(:,z)=eeg(:,i)-eeg(:,i+1);
        chan{1,z}=sprintf('%s-%s',chanNames{i},chanNames{i+1});
        z=z+1;
    else
        continue
    end
end

%Detecting events

fprintf('%s\n','---- Detecting pathological events ----');
b = fir1(64,[80 450]/(fs/2));
a = 1;
input_filtered = filtfilt(b,a,eeg_bi);
n = size(input_filtered,2);
for i = 1:n
    [~,th] = get_threshold(input_filtered(:,i),100,50,'std',5);
    try
        timestamp{i}(:,1) = find_event(input_filtered(:,i),th,2,1);
        timestamp{i}(:,2) = i;
    catch
        continue;
    end
end
T = cat(1,timestamp{:});
[~,I] = sort(T(:,1));
event.timestamp = T(I,:);
[alligned,allignedIndex,K] = getaligneddata(eeg_bi,event.timestamp(:,1),[-150 150]);
event.timestamp=event.timestamp(logical(K),:);
ttlN = size(alligned,3);
for i = 1:ttlN
    event.data(:,1,i) = alligned(:,event.timestamp(i,2),i);%raw segment
    event.data(:,2,i) = input_filtered(allignedIndex(i,:),...
        event.timestamp(i,2))*1000;%filtered segment
    event.data(:,3,i) = allignedIndex(i,:);%index
end
atf_ind = find(eliminate_noise(event.data,fs));
event.data(:,:,atf_ind) = [];
channel = event.timestamp(:,2);
channel(atf_ind)=[];
pChan = chan(event.timestamp(:,2));
pChan(atf_ind)=[];
event.timestamp(atf_ind,:)=[];
s_p = zeros(1,n);
u = unique(channel);
s = zeros(1,length(u));
for j=1:length(u)
    s(j)=length(find(channel==u(j)));
end
s_p(1,u)=s;

%Channels with event occurence rate > 2*median rate are shown. Can change as needed.
pc=chan(s_p>thr*mean(s_p));
monochan=cell(length(pc),2);
for i = 1:length(pc)
    try
        monochan(i,:) = strsplit(pc{i},'-');
    catch
        temp=strsplit(pc{i},'-');
        if length(temp)==4
            monochan(i,1)=strcat(temp(1),'-',temp(2));
            monochan(i,2)=strcat(temp(3),'-',temp(4));
        else
            error('Channel name mismatch');
        end
    end
end

fprintf('---- Done ----')
%%%%%%%%%show problematic chan%%%%%%%%%%%%%%
pathological_chan=unique(monochan(:));
pathological_event.ts=event.timestamp;
pathological_event.channel=pChan;

for i=1:length(pathological_chan)
    pathological_chan_id(i)=find(strcmp(pathological_chan{i},chanNames));
end
% for i=1:length(D.trials.events)
%     beh_ts(i)=D.trials.events(i).time*fs;
%     beh_cond{i}=D.trials.events(i).type;
% end
%exclude=exclude_trial(event.timestamp(:,1),pChan,round(beh_ts),chanNames);

