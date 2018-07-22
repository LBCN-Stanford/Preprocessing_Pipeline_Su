function LBCN_preprocessing_new(filename,sodata,badchan,task,pipeline,atf_check,dsamp,viewer)

% Pre-processing with pathological event/channel/artifact detection & elimination.
% Data epoching steps are modified from original preprocessing pipeline by Jessica.
%   Inputs:     filename:   name of data file in edf format
%               sodata  :   name of SODATA .mat
%               bch     :   index or names (cell array) of empty or corrupted channels to
%               pre-exclude.
%               task    :   which task to perform. If no input, will try
%               matching the folder name with pre-defined task names.
%               pipeline:   0 -- compute HFB externally. Generally faster.
%                           1 -- use SPM internal blocks (~standard pipeline with denoise).
%               atf_check:  0 -- no additional epoch - by - epoch data
%               quality check;
%                           1 -- only spike/artifact indicies will be
%                           stored and set to NAN for plot. No bad trials
%                           will be excluded.
%                           2 -- only bad data will be excluded, no spike
%                           detection and removal will be executed.
%                           3 -- both 1 and 2 will be used (defualt)
%                           4 -- bad data will be excluded, artifact
%                           indicies will be tapered in the high-pass
%                           filtered signal. 
%               dsamp  :    whether to reduce the sampling rate by the
%               input number. Default none.
%               viewer :    whether to use a GUI to review the results. 
%   -----------------------------------------
%   =^._.^=   Su Liu
%
%   suliu@standord.edu
%   -----------------------------------------

if nargin<1 || isempty(filename)
    filename = spm_select(inf,'any','Select file to convert',{},pwd,'.edf');
end

if nargin<2 || isempty(sodata)
    [sodata] = spm_select(inf,'mat','Select SODATA for file',{},pwd,'.mat');
end

if nargin<3 || isempty(badchan)
    badchan = [];
end

if nargin<4 || isempty(task)
    task = identify_task(sodata(1,:));
end

if nargin<5 || isempty(pipeline)
    pipeline = 0;
end
if nargin < 6 || isempty(atf_check)
    atf_check = 3;
end
if nargin < 7 || isempty(dsamp)
    dsamp = 1;
end
if nargin < 8 || isempty(viewer)
    viewer = 1;
end

%p =  task_config(task);
task_config(task);


fnamep = cell(size(filename,1),1);
evtfile = cell(size(filename,1),1);
exclude = cell(size(filename,1),1);
exclude_ts = cell(size(filename,1),1);
conditionList = cell(size(filename,1),1);
removeid = [];
DAT = cell(size(filename,1),1);
nd = zeros(size(filename,1),1);

for i = 1:size(filename,1)
    % Convert data
    %[D,Ddiod] = LBCN_convert_NKnew_rename(filename(i,:), [],0,[20 40 41 64:67 102:190]);
    [D,Ddiod] = LBCN_convert_NKnew_rename(filename(i,:),[], 1,badchan);
    if dsamp > 1 && D.fsample/dsamp >= 500
        S.D = D;
        S.fsample_new = D.fsample/dsamp;
        D = spm_eeg_downsample(S);
        S.D = Ddiod;
        Ddiod = spm_eeg_downsample(S);
        S.D = Ddiod;
    end
    fname = fullfile(D.path,D.fname);
    
    % Get events from SODATA
%     if strcmpi(task, 'MMR') || strcmpi(task,'VTCLoc') || strcmpi(task,'Animal') ...
%             || strcmpi(task,'category') || strcmpi(task,'EmotionF') || strcmpi(task,'EmotionA') ...
%             || strcmpi(task,'RACE_CAT')
%         [evtfile{i}] = LBCN_read_events_diod_sodata(Ddiod,sodata(i,:), task);
%     else
%         task = 'other';
%         %evtfile{i} = sodata(i,:);
%     end
    [evtfile{i}] = LBCN_read_events_diod_sodata(Ddiod,sodata(i,:), task);
    % Save events in SPM data file
    D = get_events_SPMformat(fname,evtfile{i});
    fnamep{i} = fullfile(D.path,D.fname);
    
    %%%%%%%%%%%%%%find pathological%%%%%%%%%%%%%%%%%
    [bch{i},exclude{i},exclude_ts{i},conditionList{i},]=find_pChan(fnamep{i},3,twepoch);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

fname = char(fnamep);
%fd = notch_meeg(fname,50,4);

for i = 1: size(filename,1)
    fd = LBCN_filter_badchans(fname(i,:),[], bch{i},1,0.5, 60);%Change to 60 if not looking at China datasets!!!
    fname1 = fullfile(fd{1}.path,fd{1}.fname);

    d = LBCN_montage(fname1);
    %fname1b = fullfile(d{1}.path,d{1}.fname);
    %d2 = montage_commonAvg_local(fname1b,bch{i});
    
    fname2 = fullfile(d{1}.path,d{1}.fname);
    
    % Epoch data using event file
    D = LBCN_epoch_bc(fname2,evtfile{i},[],fieldepoch,twepoch,bc,bcfield,twbc);
    fnameons = fullfile(D.path,D.fname);
    
    %%%%If not SPM based, only save the epoched data%%%
    if ~ pipeline
        DAT{i} = D;
        continue;
    end
    
    %%%%Otherwise continue with SPM internalblocks%%%
    [d,dtf] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fnameons,[],[],twResc);
    fnameTFons = fullfile(dtf{1}.path,dtf{1}.fname);
    fnameHFBons = fullfile(d{1}.path,d{1}.fname);
    
    % Smooth
    d = LBCN_smooth_data(fnameHFBons,smoothwin, twsmooth);
    fnamesmooth{i} = fullfile(d{1}.path,d{1}.fname);
    df{i} = spm_eeg_load(fnamesmooth{i});
    
    %%%%Examine signal quality for each epoch%%%%%%%%
    nanid = false(size(D));
    t1 = D.indsample(twsmooth(1)/1000);
    t2 = D.indsample(twsmooth(2)/1000);
    if atf_check
        for k = 1:size(D,3)
            data = squeeze(D(:,:,k));
            pre_exclude = squeeze(exclude_ts{i}(:,:,k));
            [badind, ~,~,spkts] = LBCN_filt_bad_trial(data',D.fsample,3.8,[],10,[],pre_exclude);
            switch atf_check
                case 1
                    nanid(:,:,i) = spkts';
                case 2
                    nanid(badind,:,i)=1;
                case 3
                    nanid(:,:,i) = spkts';
                    nanid(badind,:,i)=1;
                case 4
                    nanid(:,:,i) = spkts';
                    nanid(badind,:,i)=1;
                    %data(:,:,i) = fbeh';
            end
        end
    end
    nd(i)=ntrials(D);
    nanid2 = true(size(nanid));
    nanid2(:,t1:t2,:) = nanid(:,t1:t2,:);
    if ~viewer
        removeid = cat(3,removeid,nanid2);
    else
        removeid{i} = nanid2;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%Save and plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ pipeline
    
    save_plot = 0;
    method = 2;%type 1 fft; type 2 wavelet.
    % plot_cond=[1 4 5 9];%which conditions to plot
    save(fullfile(D.path,strcat('Epoched_data_',task,'.mat')),'evtfile','DAT','bch',...
        'exclude','conditionList','exclude_ts','plot_cond','twsmooth','twbc');
    LBCN_plot_HFB(evtfile,DAT,bch,exclude,conditionList,plot_cond,save_plot,method,exclude_ts,atf_check,twsmooth,twbc);
elseif viewer
        signal_all = format_signal([],df,plot_cond,exclude);
        nan_all = format_signal([],df,plot_cond,exclude);
        sparam = 25;
        labels = chanlabels(df{1});
        t = time(df{1});
        page = 1;
        yl = [-0.3 2];
        window = t1:t2;
        bc_type = 2;
        save(fullfile(D.path,strcat('Var_gui_',task,'.mat')),'df','plot_cond','exclude','bch');
        plot_window(signal_all, sparam,labels,df,window,plot_cond, page, yl, bch, t, [], bc_type, nan_all);
else
        REMOVEID = removeid(:,t1:t2,:);    
        BCH = [];
        for i = 1:length(bch)
            BCH = [BCH bch{i}];
        end
        BCH = unique(BCH);
        if ~ isempty(exclude)
            EXCLUDE = exclude{1};
        else
            EXCLUDE = [];
        end
            tomerge = char(fnamesmooth);
        if size(tomerge,1)>1 %merge multiple files
            S.D = tomerge;
            S.recode = 'same';
            D = spm_eeg_merge(S);
            final = fullfile(D.path,D.fname);
            for kk=1:nchannels(D)
                for nn=2:size(tomerge,1)
                    EXCLUDE{kk}=[EXCLUDE{kk} exclude{nn}{kk}+nd(nn-1)];
                end
            end
        else
            final = tomerge;
        end
        save(fullfile(D.path,strcat('Var_',task,'.mat')),'evtfile','plot_cond','EXCLUDE','BCH','REMOVEID','twsmooth');
        LBCN_plot_averaged_signal_epochs2(final,[],plot_cond,[], 0,task,[],[],EXCLUDE,BCH,REMOVEID);
end





