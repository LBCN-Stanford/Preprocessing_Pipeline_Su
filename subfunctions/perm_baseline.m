function [xbase1, xbase2, stdev] = perm_baseline(blmat, numIt)
% loop over all channels
%xbase1 = zeros(size(blmat,1),1);
%xbase2 = zeros(size(blmat,1),1);
%stdev = zeros(size(blmat,1),1);
for CH = 1:size(blmat,1)
    progress(CH,size(blmat,1),50,0)
    pool = squeeze(blmat(CH,:,:,:));
    pool = reshape(pool,size(pool,1),size(pool,2)*size(pool,3));
    Bootstrap = zeros(size(blmat,2),numIt);
    for fr = 1:size(blmat,2)
        for i = 1:numIt
            inds = randperm(length(pool));             % permute baseline values
            inds = inds(1:size(blmat,4));     % BL timepoints = N trials
            Bootstrap(fr,i) = nanmean(pool(fr,inds)); 
        end
    end
    xbase1(CH,:) = nanmean(Bootstrap,2);
    xbase2(CH,:) = nanmean(log10(Bootstrap),2);
    stdev(CH,:) = nanstd(Bootstrap');
end

    % Step1 - generate Baseline and Distribution
%     for fr = 1:size(blmat,2)
%     
%         % pool all baseline values in a row vector
%         pool = squeeze(blmat(CH,fr,:,:));
%         
%         pool = reshape(pool,1,size(pool,1)*size(pool,2));
% 
%         % permute this BL distribution, e.g. 1000 times
%         Bootstrap = zeros(1,numIt);
%         for i = 1:numIt
%             inds = randperm(length(pool));             % permute baseline values
%             inds = inds(1:size(blmat,3));     % BL timepoints = N trials
%             Bootstrap(i) = nanmean(pool(inds)); 
%         end
%         
%         Distrib(fr).Mean   = nanmean(Bootstrap);                 % mean
%         Distrib(fr).Std    = nanstd(Bootstrap);                  % std
%         % Distrib(fr).normal = kstest(Bootstrap);               % normality test
%         % Distrib(fr).quant  = quantile(Bootstrap,[0:0.01:1]);  % quantiles of distribution 
%         % [Distrib(fr).N,Distrib(fr).X]  = hist(Bootstrap,100); % quantiles of distribution 
%     
%     end
       
    
end     
