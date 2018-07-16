function [signalbc, signalbc2] = baseline_norm(original, window, bc_win, bc_type, badind, remove)

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
remove = repmat(remove,[1 1 1 11]);
remove = permute(remove,[1,4,2,3]);
original(remove) = nan;
for i=1:tn
    progress(i,tn,10,0)
    xx= spm_squeeze(original(:, :,window, i), 4);
    xbase = xx(:, :, bc_win-window(1)+1);
    %rpc = nanmean(xbase(~badind,:,:),1);
    %xbase(badind, :,:) = rpc;
    xbase(badind(:,i), :,:) = nan;
    stdev   =  nanstd(xbase, [], 3);
    xbase1   =  nanmean(xbase , 3);
    xbase2 = nanmean(log10(xbase),3);
    SIG(:,:,:,i)= (xx - repmat(xbase1,[1 1 slength 1]))./repmat(stdev,[1 1 slength 1]);
    %SIG2(:,:,:,i)=10*log10((xx)./ repmat(xbase,[1 1 slength 1]));
    SIG2(:,:,:,i)=10*(log10(xx) - repmat(xbase2,[1 1 slength 1]));
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