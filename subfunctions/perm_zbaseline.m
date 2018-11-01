function zspctrm = perm_zbaseline(blmat, datamat, numIt)
% data,at in a dim of trials x CH x freqs x time
% Modified by Su Liu @Stanford
%
%%%%%%%%%%%%%%%%
%
% bootstrapped baseline-correction for freq data in fieldtrip format 
% as described in Flinker (2015) PNAS, Helfrich (2017) PNAS, Helfrich (2018) Neuron

% rhelfrich@berkeley.edu

% data dim of freq has to be trials x CH x freqs x time

% insert a fieldtrip freq structure along with BLstart/BLend in FT timeaxis
% not in samples: e.g. rh_zbaseline(freq, -2, -1.5, 1000)
% numIt = bootstrap iterations

% find samples for baseline correction

%input signal SIG(:,freqID,:,:) -- chan * freq * samples * trials

% BLstart = nearest(datamat.time, BLstart);
% BLend = nearest(datamat.time,BLend);

zspctrm = zeros(size(datamat));

% loop over all channels
for CH = 1:size(blmat,1)
    % Step1 - generate Baseline and Distribution
    for fr = 1:size(blmat,2)
    
        % pool all baseline values in a row vector
        pool = squeeze(blmat(CH,fr,:,:));
        
        pool = reshape(pool,1,size(pool,1)*size(pool,2));

        % permute this BL distribution, e.g. 1000 times
        Bootstrap = zeros(1,numIt);
        for i = 1:numIt
            inds = randperm(length(pool));             % permute baseline values
            inds = inds(1:size(blmat,3));     % BL timepoints = N trials
            Bootstrap(i) = nanmean(pool(inds)); 
        end
        
        Distrib(fr).Mean   = nanmean(Bootstrap);                 % mean
        Distrib(fr).Std    = nanstd(Bootstrap);                  % std
        % Distrib(fr).normal = kstest(Bootstrap);               % normality test
        % Distrib(fr).quant  = quantile(Bootstrap,[0:0.01:1]);  % quantiles of distribution 
        % [Distrib(fr).N,Distrib(fr).X]  = hist(Bootstrap,100); % quantiles of distribution 
    
    end
        
    % Step2 - apply it to all trials at this given channel
    for tr = 1:size(datamat,1)
        
        % data that will be z transformed
        spec = squeeze(datamat(tr,CH,:,:));
        % allocate memory
        ERSPz = zeros(size(datamat,3),size(datamat,4));
        % loop across freqs
        for fr = 1:size(datamat,3)        
            ERSPz(fr,:) = (spec(fr,:) - repmat(Distrib(fr).Mean,1,size(spec,2))) ./ Distrib(fr).Std; % z score
        end
        
        zspctrm(tr,CH,:,:) = ERSPz; clear ERSPz        
    end
    
end     

end