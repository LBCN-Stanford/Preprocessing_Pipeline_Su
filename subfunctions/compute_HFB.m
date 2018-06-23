function [signalbc, signalbc2] = compute_HFB(data, fs, type, fbands, atf_check, bc_type, bc_win , pre_defined_bad, window)

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
if nargin<2 || isempty(fs)
    fs = 1000;
end
if nargin<3 || isempty(type)
    type = 1;
end
if nargin<4 || isempty(fbands)
    fbands = [70 80; 80 90; 90 100; 100 110; 110 120; 120 130;...
        130 140; 140 150; 150 160; 160 170; 170 180];
end
if nargin<5 || isempty(atf_check)
    atf_check = 3;
end
if nargin<6 || isempty(bc_type)
    bc_type = 'z';
end
if nargin<7 || isempty(bc_win)
    bc_win = 101:300;
end

if nargin<8 || isempty(pre_defined_bad)
    pre_defined_bad = false(size(data));
end

if nargin<9 || isempty(window)
    window = 101:1100;
end

cn = size(data,1);
dlength = size(data,2);
tn = size(data,3);
nanid = false(size(data));
disp('.')
 progress(1,tn,25,1)
%%%%%%%%%%% check data quality %%%%%%%%%%%%%%%%%
if atf_check
    for i = 1:tn
        progress(i,tn,25,0)
        dat = squeeze(data(:,:,i))';
        try
            inspectatf = evalin('base', 'inspectatf');
        catch
            inspectatf = 1;
        end
        [badind,fbeh,~,spkts] = LBCN_filt_bad_trial(dat,fs,[],1,15, 0.5, squeeze(pre_defined_bad(:,:,i))',inspectatf);%(data_raw,fs,spk_thr,tapers,exwin,amp,pre_defined_bad)
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
                data(:,:,i) = fbeh';
        end
    end
end

narrown = zeros(cn,size(fbands,1),dlength,tn);
switch type
    case 1
        for i=1:size(fbands,1)
            [b(i,:), a(i,:)]= fir1(32,[fbands(i,1) fbands(i,2)]/(fs/2));
        end
        for j = 1:cn
            progress(j,cn,50,0)
            dat = squeeze(data(j,:,:));%all trials in the same channels
            remove = squeeze(nanid(j,:,:));
            %badindsub = [];
            for n = 1:size(b,1)
                beh = filtfilt(b(n,:),a(n,:),dat);
                
                p1 = envelope(beh,fs);
                p1 = p1.*conj(p1);
                p1(remove) = nan;
                narrown(j,n,:,:) = p1;
            end
        end
    case 2
        for j = 1:cn
            progress(j,cn,50,0)
            dat = squeeze(data(j,:,:));
            for k = 1:tn
                [tf,F] = cwt(dat(:,k),fs);
                remove = squeeze(nanid(j,:,k));
                %[tf,t,f]=stft(dat(:,j),256,fs,128,1,1);
                %p1n = zeros(size(dat,1),length(bands)-1);
                for n = 1:(length(fbands))
                    pn = icwt(tf,F,[fbands(n,1) fbands(n,2)]);
                    pn = pn.*conj(pn);
                    %pn = envelope(abs(nb),fs);
                    pn(remove) = nan;
                    narrown(j,n,:,k) = pn;
                end
            end
        end
end
%signal = narrown;
[signalbc, signalbc2] = baseline_norm(narrown, window, bc_win, bc_type);
progress(1,1,1,1);
