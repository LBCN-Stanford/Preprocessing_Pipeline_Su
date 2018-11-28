function freq = rh_zbaseline(freq, BLstart, BLend, numIt)

% bootstrapped baseline-correction for freq data in fieldtrip format 
% as described in Flinker (2015) PNAS, Helfrich (2017) PNAS, Helfrich (2018) Neuron

% rhelfrich@berkeley.edu

% data dim of freq has to be trials x CH x freqs x time

% insert a fieldtrip freq structure along with BLstart/BLend in FT timeaxis
% not in samples: e.g. rh_zbaseline(freq, -2, -1.5, 1000)
% numIt = bootstrap iterations

% find samples for baseline correction
BLstart = nearest(freq.time, BLstart);
BLend = nearest(freq.time,BLend);

% allocate memory
freq.zspctrm = freq.powspctrm .* 0;

% loop over all channels
for CH = 1:length(freq.label)
    
     disp(['Z-scoring Channel ', num2str(CH)])

    % Step1 - generate Baseline and Distribution
    for fr = 1:length(freq.freq)
    
        % pool all baseline values in a row vector
        pool = squeeze(freq.powspctrm(:,CH,fr,BLstart:BLend));
        pool = reshape(pool,1,size(pool,1)*size(pool,2));

        % permute this BL distribution, e.g. 1000 times
        Bootstrap = zeros(1,numIt);
        for i = 1:numIt
            inds = randperm(length(pool));             % permute baseline values
            inds = inds(1:size(freq.powspctrm,1));     % BL timepoints = N trials
            Bootstrap(i) = mean(pool(inds)); 
        end
        
        Distrib(fr).Mean   = nanmean(Bootstrap);                 % mean
        Distrib(fr).Std    = nanstd(Bootstrap);                  % std
        % Distrib(fr).normal = kstest(Bootstrap);               % normality test
        % Distrib(fr).quant  = quantile(Bootstrap,[0:0.01:1]);  % quantiles of distribution 
        % [Distrib(fr).N,Distrib(fr).X]  = hist(Bootstrap,100); % quantiles of distribution 
    
    end
        
    % Step2 - apply it to all trials at this given channel
    for tr = 1:size(freq.powspctrm,1)
        
        % data that will be z transformed
        spec = squeeze(freq.powspctrm(tr,CH,:,:));
        % allocate memory
        ERSPz = zeros(length(freq.freq),length(freq.time));
        % loop across freqs
        for fr = 1:length(freq.freq)        
            ERSPz(fr,:) = (spec(fr,:) - repmat(Distrib(fr).Mean,1,size(spec,2))) ./ Distrib(fr).Std; % z score
        end
        
        freq.zspctrm(tr,CH,:,:) = ERSPz; clear ERSPz        
    end
    
end
        

end