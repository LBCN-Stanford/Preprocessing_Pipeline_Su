function [signalbc, signalbc2] = baseline_norm(original, window, bc_win, bc_type)

if isempty(original)
    signalbc =[];
    return;
end
[cn, fn, ~, tn] = size(original);
slength = length(window);
SIG=nan(cn,fn,slength,tn);
SIG2=nan(cn,fn,slength,tn);
for i=1:tn
    progress(i,tn,10,0)
    xx= spm_squeeze(original(:, :,window, i), 4);
    xbase = xx;
    stdev   =  nanstd(xbase(:, :, bc_win-window(1)+1), [], 3);
    xbase   =  nanmean(xbase(:,:, bc_win-window(1)+1),3);
    SIG(:,:,:,i)= (xx - repmat(xbase,[1 1 slength 1]))./repmat(stdev,[1 1 slength 1]);
    SIG2(:,:,:,i)=10*log10((xx)./ repmat(xbase,[1 1 slength 1]))+5;
end
switch bc_type
    case 'z'
        signalbc=squeeze(nanmean(SIG,2));
        signalbc2=squeeze(nanmean(SIG2,2));
        signalbc2=real(signalbc2);
    case 'log'
        signalbc=squeeze(nanmean(SIG2,2));
        signalbc=real(signalbc);
        signalbc2=squeeze(nanmean(SIG,2));
end
% signalbc=squeeze(nanmean(SIG,2));
% signalbc=real(signalbc);