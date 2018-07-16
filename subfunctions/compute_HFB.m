function [signalbc, signalbc2,nanid] = compute_HFB(data, fs, type, fbands, atf_check, ...
    bc_type, bc_win , pre_defined_bad, window, downsamp)

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
    fs = 1000;
end
if (nargin<3 || isempty(type)) 
    type = 1;
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
    window = 101:1100;
end

if nargin<10 || isempty(downsamp)
    downsamp = 2;
end

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
        progress(i,tn,25,0)
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
                    fs,[],0, 10, 0.5, squeeze(pre_defined_bad(:,:,i))',inspectatf);
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
                    fs,[],0, 10, 0.5, squeeze(pre_defined_bad(:,:,i))',inspectatf);
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
            [b(i,:), a(i,:)]= fir1(20,[fbands(i,1) fbands(i,2)]/(fs/2));
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
        env = hilbert(filtered_signal);
        env = env.*conj(env);
        narrown = permute(env,[1,4,2,3]); %cn x fn x dn xtn
    case 2
        t = 1*1000/fs;
        wvmat = wv_morlet(6, t, fbands);
        narrown = zeros(cn,size(fbands,1),ceil((dlength_org)/downsamp) ,tn);
        for k = 1:tn
            progress(k,tn,50,0)
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
bc_win = round((bc_win(1) : downsamp : bc_win(end))./downsamp);
nanid = nanid(:,1:downsamp:end,:);
%signal = narrown;
[signalbc, signalbc2] = baseline_norm(narrown, window, bc_win, bc_type, bad, nanid);
progress(1,1,1,1);
