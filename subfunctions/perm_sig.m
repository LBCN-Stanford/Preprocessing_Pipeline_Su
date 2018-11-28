function [xxperm] = perm_sig(datamat, numIt)
for CH = 1:size(datamat,1)    
    for sm = 1:size(datamat,3)
    pool = squeeze(datamat(CH,:,sm,:));
    pool = reshape(pool,size(pool,1),size(pool,2)*size(pool,3));
    %Bootstrap = zeros(size(datamat,2),size(datamat,3),numIt);
    for fr = 1:size(datamat,2)
        for i = 1:numIt
            inds = randperm(length(pool));             % permute baseline values
            inds = inds(1);     % BL timepoints = N trials
            Bootstrap(fr,sm,i) = nanmean(pool(fr,inds)); 
        end
    end
    end
    xxperm(CH,:,:) = nanmedian(Bootstrap,3);
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
