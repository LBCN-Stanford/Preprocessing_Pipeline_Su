
function [evt] = get_events_clin_diod(fname,np,v, thresh_dur,skip,skipp)

% function to detect events on the diod, seen as a channel in the SPM MEEG
% object (D). 
% inputs:
% - fname : name of the file containing the diod signal
% - np    : number of the diod electrode
% - v     : threshold on normalized diod, default 0.5.
% - thresh_dur : minimal duration of each event (in seconds)
% - skip  : number of events to skip at the beginning (starting sequence)
% - skipp : number of events to skip at the end (ending sequence)
% output:
% evt : structure with fields onsets, offsets and durations (in seconds)
%--------------------------------------------------------------------------
% Written by J. Schrouff, Laboratory of Behavioral and Cognitive
% Neuroscience, Stanford University, 10/01/2014.

% Get inputs and parameters
def = get_defaults_Parvizi;
if nargin<1 || isempty(fname)
    fname = spm_select(1,'.mat','Select file containing diod signal',[],pwd,'.mat');
end
D = spm_eeg_load(fname);
if nargin<2 || isempty(np)
    np = D.nchannels;    % by default, select last channel
end
if nargin<3 || isempty(v)
    v = 0.5;  % by default, get one time the std on the diff
end
if nargin<4
    thresh_dur = def.thresh_dur; % by default, no minimum duration on events
end
if nargin<5
    skip = 0;
end

if nargin <6
    skipp = 0;
end

% Find events using the differential of the signal and the standard
% deviation
pdio = D(np,:)/max(D(np,:));
% mp = mean(pdio(pdio>0));
% minp = mean(pdio(pdio<0));
% sp = std(pdio(pdio>0));
% minsp = std(pdio(pdio<0));
xx = diff(pdio);
% tmp = zeros(1,length(xx));
ons = find(xx>v); %onsets, no filtering
off = find(xx<-v); %offsets

onsets = ons(1);
offsets = off(1);

don = diff(ons);
dof = diff(off);
% due to noise, can have onsets that are very close, discard those if less
% than 200ms apart.
for i = 1:length(don)
    if don(i)> 0.2*D.fsample
        onsets = [onsets,ons(i+1)];
    end
end
for i = 1:length(dof)
    if dof(i)> 0.2*D.fsample
        offsets = [offsets,off(i+1)];
    end
end

% see if we missed any offset or onset
if onsets(1)<offsets(1)
    if length(onsets)<length(offsets)
        disp('Missing event onsets at the end')
        offsets = offsets(1:length(onsets));
    elseif length(onsets)>length(offsets)
        disp('Missing event offsets at the beginning')
        j=2;
        while offsets(1)<onsets(j)
            j = j+1;
        end
        onsets = onsets(j-1:end);
        if length(onsets)>length(offsets) %missing offsets at the end
            onsets = onsets(1:length(offsets));
        end
    else
        disp('Onsets and offsets seem to be matching')
    end
elseif onsets(1)>offsets(1)
    disp('Missing event onsets at the beginning')
    j=2;
    while onsets(1)<offsets(j)
        j = j+1;
    end
    offsets = offsets(j:end);
end

% get the duration of the events and discard according to threshold (e.g. discard starting sequence)
if length(onsets)~=length(offsets)
    disp('Mismatch between the onsets and offsets, review')
    disp('Exiting without saving')
else
    dur = offsets - onsets;
    ind = dur>=thresh_dur*D.fsample;
    aa  = find(ind);
    ind = aa(1+skip):aa(end-skipp);
    evt = struct('onsets',onsets(ind)/D.fsample, 'offsets',...
        offsets(ind)/D.fsample,'durations',dur(ind)/D.fsample);
%      save([D.path,filesep,'events_from_clin_diod.mat'],'evt')
end


    
            
            
    
        



