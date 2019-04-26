function [signalbc, signalbc2,nanid, spec, spec2] = compute_HFB(data, fs, type, fbands, atf_check, ...
    bc_type, bc_win , pre_defined_bad, window, downsamp, spec_all)

if nargin<1 || isempty(data)
    [filename,pathname] = uigetfile({'*.mat','Data format (*.mat)'});
    names = fullfile(pathname,filename);
    try
        D = spm_eeg_load(names);
        data = D(:,:,:);
        fs = D.fsample;
    catch
        D = load(names);
        data = getfield(D,char(fieldnames(D)));
        fs = 1000;
    end
end
if (nargin<2 || isempty(fs)) && ~exist('fs','var')
    try
        D = spm_eeg_load(names);
        data = D(:,:,:);
        fs = D.fsample;
    catch
        fs = 1000;
    end
end
if (nargin<3 || isempty(type)) 
    type = 2;
end
if nargin<4 || isempty(fbands)
%     fbands = [70 80; 80 90; 90 100; 100 110; 110 120; 120 130;...
%         130 140; 140 150; 150 160; 160 170; 170 180];
    fbands = linspace(70,180,12);        
end
if (nargin<5 || isempty(atf_check))  && ~exist('atf_check','var')
    atf_check = 3;
end
if (nargin<6 || isempty(bc_type)) && ~exist('bc_type','var')
    bc_type = 'z';
end
if (nargin<7 || isempty(bc_win)) && ~exist('bc_win','var')
    bc_win = 101:300;
end

if nargin<8 || isempty(pre_defined_bad)
    pre_defined_bad = false(size(data));
end

if (nargin<9 || isempty(window)) && ~exist('window','var')
    window = 101:round(101*fs/1000:1100*fs/1000);
end

if nargin<10 || isempty(downsamp)
    downsamp = 2;
end
if nargin<11 || isempty(spec_all)
    %spec_all = linspace(0,180,19);
    spec_all = linspace(0,200,21);
end
%
%spec_all = fbands;
spec_all(1) = 1;
cn = size(data,1);
dlength_org = size(data,2);
dlength = length(1 : downsamp : dlength_org);
tn = size(data,3);
bad = false(cn, tn);
nanid = false(size(data));
cf = fbands(1:end-1)+(fbands(2)-fbands(1))/2; % center frequencies
disp('.')
 progress(1,tn,25,1)
%% check data quality %%%%%%%%%%%%%%%%%
if atf_check
    bad = false(cn, tn);
    for i = 1:tn
        progress(i,tn,10,0)
        dat = squeeze(data(:,:,i))';
        try
            inspectatf = evalin('base', 'inspectatf');
        catch
            inspectatf = 1;
        end
        %% Inputs for artifact rejection: (data_raw,fs,spk_thr,tapers,exwin,amp,pre_defined_bad)
        switch atf_check
            case 1 
                %mark spiky data points +/- 10 ms. 
                %Bad epochs will not be removed but will be excluded from baseline calculation.
                
                [badind,~,~,spkts,badind2] = LBCN_filt_bad_trial(dat,...
                    fs,[],0, 10, 0.6, squeeze(pre_defined_bad(:,:,i))',inspectatf);
                nanid(:,:,i) = spkts';
                badind(badind2) = 1; 
            case 2 
                %for data with overall good quality. 
                %Mark spiky data points +/- 2 ms to minimize the unnecessary deduction of data. 
                %Bad epochs wil be removed.
                
                [badind,~,~,spkts] = LBCN_filt_bad_trial(dat,...
                    fs,[],0, 2, 0.4, squeeze(pre_defined_bad(:,:,i))',inspectatf);
                 nanid(:,:,i) = spkts';
                 nanid(badind,:,i)=1;
                
            case 3 
                %should be good for most of the datasets. 
                %Mark spiky data points +/- 10 ms. 
                %Bad epochs wil be removed. 
                %Both bad and spiky epochs will be excluded from baseline calculation.
                
                [badind,~,~,spkts,badind2] = LBCN_filt_bad_trial(dat,...
                    fs,[],0, 10, 0.6, squeeze(pre_defined_bad(:,:,i))',inspectatf);
                nanid(:,:,i) = spkts';
                nanid(badind,:,i)=1;
                badind(badind2) = 1;
                
            case 4 
                % for noisy data may consider removing the corrupted segments and taper with neighboring signal. 
                
                [badind,fbeh,~,spkts,badind2] = LBCN_filt_bad_trial(dat,...
                    fs,[],1, 10, 0.3, squeeze(pre_defined_bad(:,:,i))',inspectatf);
                nanid(:,:,i) = spkts';
                nanid(badind,:,i)=1;
                data(:,:,i) = fbeh';
                badind(badind2) = 1;

        end
    end
    bad(:,i) = badind;
end


switch type
    case 1
        
        fbands = [70 80; 80 90; 90 100; 100 110; 110 120; 120 130;...
        130 140; 140 150; 150 160; 160 170; 170 180];
        for i=1:size(fbands,1)
            [b(i,:), a(i,:)]= fir1(64,[fbands(i,1) fbands(i,2)]/(fs/2));
        end
        data = permute(data,[2,1,3]);%dn x cn x tn
        %remove = permute(nanid,[2,1,3]);
        filtered_signal = zeros([cn dlength tn length(cf)]);
        %iir_multi = load('iir70_180.mat');
        for m = 1:tn
            progress(m,tn,30,0)
            for n = 1:length(cf)
                    f_signal = filtfilt(b(n,:), a(1,:), data(:,:,m));
                    filtered_signal(:,:,m,n) = f_signal(1 : downsamp : end,:)';
            end
        end
        env = abs(hilbert(filtered_signal.^2));
        
        env = env.*conj(env);
        narrown = permute(env,[1,4,2,3]); %cn x fn x dn xtn
    case 2
        t = 1*1000/fs;
        wvmat = wv_morlet(7,t,spec_all);
        fa = abs(spec_all - fbands(1));
        fb = abs(spec_all - fbands(end));
        freqID = find(fa==min(fa)) : find(fb==min(fb));
        %wvmat = wv_morlet(7, t, fbands);
        fbands = spec_all;
        narrown = zeros(cn,size(fbands,1),ceil((dlength_org)/downsamp) ,tn);
        for k = 1:tn
            progress(k,tn,30,0)
            for j = 1:cn
                for i = 1:length(wvmat)
                    tmp = conv(data(j, :,k), wvmat{i});
                    tmp = tmp((1:dlength_org) + (length(wvmat{i})-1)/2);
                    tmp = tmp(1:downsamp:end);
                    narrown(j, i, :,k) = tmp;
                end
            end
        end
        narrown = narrown.*conj(narrown);
end
window = round((window(1) : downsamp : window(end))./downsamp);
nanid = nanid(:,1:downsamp:end,:);
%signal = narrown;
if ~exist('freqID','var')
    freqID = 1:size(fbands,1);
end
if ~isnumeric(bc_win)%use a specific condition as baseline; 
    bls = str2num(bc_win{2})/downsamp;
    ble = str2num(bc_win{3})/downsamp;
    if ble > size(narrown,3)
        ble = size(narrown,3);
    end
    if bls < 0 && ble > 300/downsamp
        bls = ble-300/downsamp;
    end
    bc_sig = narrown(:,:,round(bls:ble),bc_win{1});
    [signalbc, signalbc2, spec, spec2] = baseline_norm2(narrown, window, bc_sig, bc_type, bad, nanid, freqID, 0);
else
    bc_win = round((bc_win(1) : downsamp : bc_win(end))./downsamp);
    bc_win(bc_win < window(1)) = [];
    [signalbc, signalbc2, spec, spec2] = baseline_norm(narrown, window, bc_win, bc_type, bad, nanid, freqID, 0);
end

nanid=nanid(:,window,:);
progress(1,1,1,1);
