function [sig_chan, p_perchan, p_thresh, pchan_WSR] = permutation_test_old(signal,win_bl,win_bh,chanid,nperm,tail)
if nargin<4 || isempty(chanid)
    chanid = 1:length(signal);
end

if nargin<5 || isempty(nperm)
    nperm = 2500;
end

if nargin<6 || isempty(tail)
    tail = 0;
end
permutation = zeros(size(signal{1},2),nperm);
p_perchan = zeros(length(chanid),1);
pchan_WSR = zeros(length(chanid),1);
for i = 1:length(chanid)
    if size(signal{i},2) < size(signal{1},2)
        missing = size(signal{1},2) - size(signal{i},2);
        signal{i}(:,end+1:end+missing) = nan;%padding missing trials
    end
    % Counter of channels to be updated
    %win_bl=200:550;
        conddata = nanmean(signal{i}(win_bh,:),1);
        baseline = nanmean(signal{i}(win_bl,:),1);
    if tail
        truediff = (nanmedian(conddata - baseline));
    else
        truediff = abs(nanmedian(conddata - baseline));
    end
    try
        pchan_WSR(i) = signrank(conddata-baseline);
    catch
        pchan_WSR(i) = 1;
         p_perchan(i) = 1;
         continue;
    end
    perm = zeros(size(signal{1},2),nperm);
    permdiff = zeros(nperm,1);
    for p = 1:nperm
        if i == 1
            % Need to set the permutation matrix
            indperm = rand(numel(conddata),1);
            permutation(:,p) = indperm;
        end
        perm(:,p) =  permutation(:,p);       
        diff = conddata - baseline;
        multp = ones(numel(conddata),1);
        multp(perm(:,p)>0.5) = -1;
        diffp = diff' .* multp;
        if tail
            permdiff(p) = (nanmedian(diffp));
        else
            permdiff(p) = abs(nanmedian(diffp));
        end
    end
    permdiff = [permdiff;truediff];
    p_perchan(i) = length(find(permdiff>=truediff))/(nperm + 1);
end

% Correct for multiple comparisons using FDR
[p_thresh,pass] = LBCN_FDRcorrect(p_perchan);
sig_chan = find(pass);