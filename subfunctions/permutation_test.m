function [sig_channel, pval, sig_t] = permutation_test(signal,onset,nperm,tail)
% Computes significant channels and timestamps per channel.
% Outputs are significant channel id, pvalues, and a matrix that marks
% significant timestamps for plotting. 
%
if nargin<3 || isempty(nperm)
    nperm = 500;
end

if nargin<4 || isempty(tail)
    tail = 0;
end
sig_chan = false(1,length(signal));
dn = size(signal{1},1);
pval = ones(length(signal),dn);
for j = 1:length(signal)
    try
        dat=[];
        dat(1,:,:) = signal{j};
        pval(j,:) = clust_perm_sc(dat,[],nperm);
    catch

    end
    sig_ts = find(pval(j,:) <= 0.05);
    if ~isempty(sig_ts)
        fsig = find(sig_ts >= onset);
        if any(fsig) && length(fsig) > (dn / 30)
          sig_chan(j) = true;
        end
    end
end
pval = pval';
sig_channel = find(sig_chan);
sig_t = double(pval <= 0.05);
sig_t(sig_t == 0) = nan;
sig_t = sig_t-1; % This is for plotting
