function script_ALLPreprocessing_MMR_example(filename,sodata,bch,task)

% Function to perform full pre-processing and univariate analysis for a
% specific block of edf data.
% Inputs:
% - filename: name of data file in edf format (optional)
% - sodata  : name of SODATA .mat (optional)
% - bch     : indexes or names (cell array) of pathological channels to
%             exclude.
% - task    : which task to perform, either 'MMR' (default), 'VTCLoc','Other'
% -------------------------------------------------------------------------

% Get inputs
if nargin<1 || isempty(filename)
    filename = spm_select(inf,'any','Select file to convert',{},pwd,'.edf');
end

if nargin<2 || isempty(sodata)
    sodata = spm_select(inf,'mat','Select SODATA for file',{},pwd,'.mat');
end

if nargin<3 || isempty(bch)
    bch = [];
end

if nargin<4 || isempty(task)
    task = 'category';
end

RTbased = 0;
switch task
    case 'MMR'
        fieldepoch = 'start';
        twepoch = [-300 2200]; %Max of RTs as default
        bc = 1;
        bcfield = 'start';
        twbc = [-150 0];
        twResc = [-150 0];
        smoothwin = 100;
        twsmooth = [-150 2000];
        RTbased = 1;
        twsmoothRT = [-2000 150];
        fieldepochRT = 'RTons';
        twepochRT = [-2200 300];
    case 'VTCLoc'
        fieldepoch = 'start';
        twepoch = [-300 500];
        bc = 1;
        bcfield = 'start';
        twbc = [-200 0];
        smoothwin = 50;
        twResc = [-200 0];
        twsmooth = [-100 400];
    case 'Animal'
        fieldepoch = 'start';
        twepoch = [-200 700];
        bc = 1;
        bcfield = 'start';
        twbc = [-200 0];
        smoothwin = 50;
        twResc = [-100 0];
        twsmooth = [-100 600];
    case 'category'
        fieldepoch = 'start';
        twepoch = [-300 850];
        bc = 1;
        bcfield = 'start';
        twbc = [-200 0];
        smoothwin = 50;
        twResc = [-200 0];
        twsmooth = [-200 800];
    case 'other'
        fieldepoch = 'start';
        twepoch = [-200 1200];
        bc = 1;
        bcfield = 'start';
        twbc = [-200 0];
        twResc = [-100 0];
        smoothwin = 100;
        twsmooth = [-100 1000];
end

fnamep = cell(size(filename,1),1);
evtfile = cell(size(filename,1),1);
for i = 1:size(filename,1)
    % Convert data
    [D,Ddiod] = LBCN_convert_NKnew(filename(i,:), [],0);
    fname = fullfile(D.path,D.fname);

    % Get events from SODATA - if MMR or VTCLoc, otherwise assumes the sodata
    % corresponds to the events.categories
    if strcmpi(task, 'MMR') || strcmpi(task,'VTCLoc') || strcmpi(task,'Animal') || strcmpi(task,'category')
        [evtfile{i}] = LBCN_read_events_diod_sodata(Ddiod,sodata(i,:), task);
    else
        evtfile{i} = sodata(i,:);
    end

    % Save events in SPM data file
    D = get_events_SPMformat(fname,evtfile{i});
    fnamep{i} = fullfile(D.path,D.fname);
end
fname = char(fnamep);
% Filter data and detect bad channels

fd = LBCN_filter_badchans(fname,[], bch,1,0.5);

fnamesmooth = cell(size(filename,1),1);
fnamesmoothRT = cell(size(filename,1),1);
for i = 1: numel(fd)
    
    fname = fullfile(fd{i}.path,fd{i}.fname);
    
    % Montage
    d = LBCN_montage(fname);
    fname = fullfile(d{1}.path,d{1}.fname);
    
    % Epoch data using event file
    D = LBCN_epoch_bc(fname,evtfile{i},[],fieldepoch,twepoch,bc,bcfield,twbc); 
    fnameons = fullfile(D.path,D.fname);
    
    % Perform artifact rejection, TF
    [d,dtf] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fnameons,[],[],twResc);
    fnameTFons = fullfile(dtf{1}.path,dtf{1}.fname);
    fnameHFBons = fullfile(d{1}.path,d{1}.fname);
    
    % Smooth results for visualization
    d = LBCN_smooth_data(fnameHFBons,smoothwin, twsmooth);
    fnamesmooth{i} = fullfile(d{1}.path,d{1}.fname);
    
    if RTbased
        % Epoch based on RT, correct based on onset
        D = LBCN_epoch_bc(fname,evtfile{i},[],fieldepochRT,twepochRT,bc,bcfield,twbc,'RT');
        fnameons = fullfile(D.path,D.fname);
        
        % Perform artifact rejection, TF
        [d] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fnameons,[],fnameTFons,twResc);
        fnameTFRT = fullfile(d{1}.path,d{1}.fname);       
        
        % Smooth results for visualization, RT based
        d = LBCN_smooth_data(fnameTFRT,smoothwin, twsmoothRT);
        fnamesmoothRT{i} = fullfile(d{1}.path,d{1}.fname);
    end
end
tomerge = char(fnamesmooth);

if size(tomerge,1)>1 %merge multiple files
    S.D = tomerge;
    S.recode = 'same';
    D = spm_eeg_merge(S);
    final = fullfile(D.path,D.fname);
else
    final = tomerge;
end 

%Do the same for RT based if requested
if RTbased
    tomerge = char(fnamesmoothRT);
    
    if size(tomerge,1)>1 %merge multiple files
        S.D = tomerge;
        S.recode = 'same';
        D = spm_eeg_merge(S);
        finalRT = fullfile(D.path,D.fname);
    end
    % Plot the HFB for all conditions
    LBCN_plot_averaged_signal_epochsRT(final,finalRT,[],[],[],[], 1,task);
else
    % Plot the HFB for all conditions
    LBCN_plot_averaged_signal_epochs(final,[],[],[], 1,task);
end

% Perform simple univariate analysis: each condition versus baseline




