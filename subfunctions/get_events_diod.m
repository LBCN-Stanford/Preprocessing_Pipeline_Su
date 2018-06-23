
function [evt] = get_events_diod(fname, task, ichan, skip_before, skip_after, thresh_dur)

% function to detect events on the diod, seen as a channel in the SPM MEEG
% object (DC channel exported from .edf) or load .mat with diod signal (as
% with TDT system). 
% Inputs:
% - fname : name of file to load
% - ichan: number of the diod electrode (default: 2 for new NK, empty for TDT)
% - skip_before: number of events to skip at the beginning (starting sequence)
% - skip_after: number of events to ignore at the end (ending sequence)
% - thresh_dur : minimal duration of each event (in seconds, default: 0)
% output:
% evt : structure with fields onsets, offsets and durations (in seconds)
%--------------------------------------------------------------------------
% Written by J. Schrouff, Laboratory of Behavioral and Cognitive
% Neuroscience, Stanford University, 10/01/2014.

% Get inputs and parameters
% -------------------------------------------------------------------------
def = get_defaults_Parvizi;
if nargin<1 || isempty(fname)
    fname = spm_select(1,'.mat','Select file containing diod signal',[],pwd,'.mat');
end
if nargin<2 || isempty(task)
    task = 'other';
end
deftask = getfield(def, task);
try
    D = spm_eeg_load(fname);
    if nargin<3 || isempty(ichan)
        diod = D(def.ichan,:); 
    else
        diod = D(ichan,:);
    end
    samp_rate = fsample(D);
    paths = D.path;
catch
    load(fname);
    if exist('anlg','var')
        diod = anlg;
        samp_rate = def.fsample_diod;
        paths = fileparts(fname);
    else
        fprintf('----Default trigger channel %d seems incorrect, updating ...----\n',def.ichan);
        def.ichan = find_diod(fname);
        [evt] = get_events_diod(fname, task, def.ichan, skip_before, skip_after, thresh_dur);
        assignin('caller','def',def);
        fprintf('-----New trigger channel %d identified, assigning ...-----\n',def.ichan);
        return;
    end
end
diod = diod/max(diod);

if nargin<4
    skip_before = deftask.skip_before; % do not skip events
end

if nargin<5
    skip_after = deftask.skip_after; % do not discard events at the end
end

if nargin<6
    thresh_dur = deftask.thresh_dur; % minimum duration of an event
end

% Find events using the values in Volts
% -------------------------------------------------------------------------

%(1) binarize the signal
tmp = zeros(length(diod),1);
tmp(diod>0.3) = 1;

%(2) get differential and define onsets/offsets
xx = diff(tmp);
onsets = find(xx==1); %onsets, no filtering
offsets = find(xx==-1); %offsets
% 
% onsets = ons(1);
% offsets = off(1);
if isempty(onsets) || isempty (offsets)
    fprintf('----Default trigger channel %d seems incorrect, updating ...----\n',def.ichan);
    def.ichan = find_diod(fname);
    [evt] = get_events_diod(fname, task, def.ichan, skip_before, skip_after, thresh_dur);
    assignin('caller','def',def);
    fprintf('-----New trigger channel %d identified, assigning ...-----\n',def.ichan);
    return;
end

if strcmp(task,'RACE_CAT')
    onsets = onsets(1:2:length(onsets)-1);
    offsets = offsets(1:2:length(offsets)-1);
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
    j=1;
    while onsets(1)>offsets(j)
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
    ind = dur>=thresh_dur*samp_rate;
    aa  = find(ind);
    ind = aa(1+skip_before:end - skip_after);
    evt = struct('onsets',onsets(ind)'/samp_rate, 'offsets',...
        offsets(ind)'/samp_rate,'durations',dur(ind)'/samp_rate);
    save([paths,filesep,'onsets_from_diod.mat'],'evt')
end


    
            
            
    
        



