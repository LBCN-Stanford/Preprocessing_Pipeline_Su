function [signalbc, signalbc2, spec, spec2] = baseline_norm2(original, window, bc_sig, bc_type, badind, remove, freqID, perm)
if isempty(original)
    signalbc =[];
    return;
end
if nargin < 5 || isempty(badind)
    badind = false(size(original), 1);
end

if nargin < 6 || isempty(remove)
    remove = false(size(original));
end
if nargin < 7 || isempty(freqID)
    freqID = 1:size(original,2);
end
if nargin < 8 || isempty(perm)
    perm = 0;
end

[cn, fn, ~, tn] = size(original);
% if window(1) <=0
%     window = window-window(1)+1;
%     bc_win = bc_win-bc_win(1);
%     bc_win(1) = [];
% end
    
%     window(window)
slength = length(window);
SIG=nan(cn,fn,slength,tn);
SIG2=nan(cn,fn,slength,tn);
remove = repmat(remove,[1 1 1 fn]);
remove = permute(remove,[1,4,2,3]);
originalb=original;
original(remove) = nan;
if perm == 1
    [xbase1, xbase2, stdev] = ...
        perm_baseline(bc_sig(:,:,:,:), 100);
else
    xbase = nanmean(bc_sig,4);
end
for i=1:tn
    progress(i,tn,10,0)
    %xx= spm_squeeze(original(:, :,window, i), 4);
    %xbase = xx(:, :, bc_win-window(1)+1);
    xx= spm_squeeze(originalb(:, :,window, i), 4);
    xx(badind(:,i), :,:) = nan;
    %rpc = nanmean(xbase(~badind,:,:),1);
    %xbase(badind, :,:) = rpc;
    if perm == 0
        xbase(badind(:,i), :,:) = nan;
        stdev   =  nanstd(xbase, [], 3);
        xbase1   =  nanmean(xbase , 3);
    %xbase2 = nanmean(log10(xbase),3);
        xbase2 = nanmean(sqrt(xbase),3);
    end
    SIG(:,:,:,i)= (xx - repmat(xbase1,[1 1 slength 1]))./repmat(stdev,[1 1 slength 1]);
    %SIG2(:,:,:,i)=10*log10((xx)./ repmat(xbase,[1 1 slength 1]));
    SIG2(:,:,:,i)=10*(log10(xx) - repmat(xbase2,[1 1 slength 1]));
end
switch bc_type
    case 'z'
        signalbc=squeeze(nanmean(SIG(:,freqID,:,:),2));
        signalbc2=squeeze(nanmean(SIG2(:,freqID,:,:),2));
        signalbc2=real(signalbc2);
    case 'log'
        signalbc=squeeze(nanmean(SIG2(:,freqID,:,:),2));
        signalbc=real(signalbc);
        signalbc2=squeeze(nanmean(SIG(:,freqID,:,:),2));
end
signalbc = signalbc - mean(signalbc(:,5:round(slength*0.2),:),2); 
signalbc2 = signalbc2 - mean(signalbc2(:,5:round(slength*0.2),:),2); 
spec = SIG;
spec2 = SIG2;
% signalbc=squeeze(nanmean(SIG,2));
% signalbc=real(signalbc);
