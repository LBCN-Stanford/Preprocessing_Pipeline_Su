function [D,lab_chans] = Convert_NKiEEG_to_SPMfa(fchan,fev,bch,ord)

% -------------------------------------------------------------------------
% Function to convert Nihon Kohden iEEG (raw ECoG data in .m00 format, 
% exported from NK in -ascii) to an SPM MEEG file array, including events 
% onsets and durations. 
% Inputs:
% - fchan: the full file name
% - fev: the event file name (optional, default: no event)
% - bch: indexes of the bad channels AFTER re-ordering (i.e. bad channels 
%        in the TDT file, optional, default: no bad channel). These will
%        not be included in the MEEG object.
% - ord: indexes to re-order the channels to match TDT data. (optional).
% Outputs:
% - D: the MEEG object containing specified events, with bad channels
%      discarded.
% - lab_chans: original labels of the channels, to check that the
%      re-ordering was performed correctly.
% No pre-processing such as filtering or downsampling is performed.
%--------------------------------------------------------------------------
% Written by J. Schrouff, 10/17/2013, Stanford University


% Get the file and load info from its header
if nargin<1 || isempty(fchan)
    fchan = spm_select(1,[],'Select .m00 file');
    if isempty(fchan)
        return
    end
end
disp('Reading information from header...')
fid = fopen(fchan);
header = textscan(fid,'%s %s %s %s %s %s',1,'Delimiter',' ');
for i=1:4
    in = strfind(header{i}{1},'=');
    header{i} = header{i}{1}(in+1:end);
end
nsampl = str2double(header{1}); % get the number of TimePoints
nchan = str2double(header{2}); % get the number of Channels
fsample = (1/str2double(header{4}))*1000; % get the sampling rate
disp(['TimePoints:',num2str(nsampl)])
disp(['Channels:',num2str(nchan)])
disp(['Sampling rate:',num2str(fsample)])
% get channel names from header as well
formatspec = repmat('%s ',1,nchan);
lab_chans = textscan(fid,formatspec,2,'Delimiter',' ');
for i=1:length(lab_chans)
    iref = strfind(lab_chans{i}{1},'-'); %take the reference out of the channel name
    lab_chans{i} = lab_chans{i}{1}(1:iref-1);
end

[d1,fname] = fileparts(fchan);

%Gather info about channel ordering and bad channels
if nargin<3
    bch = [];
end
if nargin<4 || isempty(ord)
    ord = 1:nchan; % in the future, create interface to re-order channels using lab_chans
end
ordchan = 1:nchan;
if ~isempty(bch)
    [tok,itk] = setdiff(ordchan,bch);
else
    itk = 1:nchan;
end
ord = ord(itk);
namchan = cell(length(ord),1);
for i=1:length(ord)
    namchan{i} = ['iEEG_',num2str(itk(i))];
end
lab_chans = lab_chans(ord);

% Start filling the data structure D
D = [];
D.Fsample = fsample;


clear segarray;
block_size = 30000;
format = repmat('%d',1,nchan);
file_id = fopen(fchan);
i=1;
istart = 1;
iend = istart + block_size-1;

while ~feof(file_id)
    segarray = textscan(file_id,format,block_size,'HeaderLines',2);
    segarray = cell2mat(segarray);
    segarray = segarray';    
    if i==1 %create empty MEEG file with right number of samples and channels
        if nsampl==0
           nsampl = length(wave);
        end
        D.path = d1;
        D.data.fnamedat = ['spm8_',fname,'.dat'];
        D.data.datatype = 'float32-le';
        D.fname = ['spm8_',fname,'.mat'];
        D.Nsamples = nsampl;
        datafile = file_array(fullfile(D.path, D.data.fnamedat), [length(ord) nsampl], 'float32-le');
        % physically initialise file
        datafile(end,end) = 0;
    end
    if i>1
        istart =istart + block_size;
        iend = istart + size(segarray,2)-1;
    end
    datafile(:,istart:iend) = segarray(ord,:);
    disp(['Reading block ',num2str(i), ' ...'])
    i=i+1;    
end
fclose(file_id);

%Deal with channel information
D.channels = struct('bad',repmat({0}, 1, length(ord)),...
    'type', repmat({'EEG'}, 1, length(ord)),...
    'label', namchan');

%Deal with trial/event information
if nargin<3
    fev = spm_select(1,'mat','Select event file for dataset');
end
if isempty(fev)
    % Create empty event field and transform into SPM MEEG object
    evtspm=[];
    D.trials.label = 'Undefined';
    D.trials.events = evtspm;
    D.trials.onset = 1/D.Fsample;
    %Create and save MEEG object
    D = meeg(D);
    save(D);
else
    %get the events from each category into the structure
    load(fev)
    if ~exist('events','var')
        warning('Could not extract events from file, should be in Parvizi structure')
    else
        if ~isfield(events,'categories')
           warning('Could not extract events from file, should be in Parvizi structure')
        end
    end
    [D] = get_events_SPMformat(events,D); % returns a SPM MEEG object with events
end
disp('done')



