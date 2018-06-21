function ichan = find_diod(fname)


    D = spm_eeg_load(fname);
    for i=1:D.nchannels
        check = D(i,:); 
        check = check/max(check);
        tmp = zeros(length(check),1);
        tmp(check>0.3) = 1;
        xx = diff(tmp);
        onsets = find(xx==1, 1); %onsets, no filtering
        offsets = find(xx==-1, 1); %offsets
        if isempty(onsets) || isempty (offsets)
            continue;
        end
        ichan = i;
    end
end