function signalbc = baseline_norm(original, window, bc_win, bc_type)

if isempty(original)
    signalbc =[];
    return;
end
[cn, fn, ~, tn] = size(original);
slength = length(window);
SIG=nan(cn,fn,slength,tn);

for i=1:tn

    progress(i,tn,10,0)
    xx= spm_squeeze(original(:, :,window, i), 4);
    xbase = xx;
    stdev   =  nanstd(xbase(:, :, bc_win-window(1)+1), [], 3);
    xbase   =  nanmean(xbase(:,:, bc_win-window(1)+1),3);
    switch bc_type
        case 'z'
            SIG(:,:,:,i)= (xx - repmat(xbase,[1 1 slength 1]))./repmat(stdev,[1 1 slength 1]);
            
        case 'log'
            SIG(:,:,:,i)=10*log10((xx)./ repmat(xbase,[1 1 slength 1]))+5;
    end
end
signalbc=squeeze(nanmean(SIG,2));
signalbc=real(signalbc);