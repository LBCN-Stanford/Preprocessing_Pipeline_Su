

cond= [K.conds]';
        cond = cond(goodtrials);
        if ~isempty(deftask.listcond)
            categNames = deftask.listcond;
        else
            Names = cellstr(num2str(unique(cond)'));
            categNames = strsplit(Names{1},' ');
        end
        stimNum= 1:length(stim_onset);
        
        for ci=1:length(categNames)
            events.categories(ci).name= sprintf('%s',categNames{ci});
            events.categories(ci).categNum= ci;
            events.categories(ci).numEvents= sum(cond==ci);
            events.categories(ci).start= stim_onset(find(cond==ci));
            events.categories(ci).duration= stim_dur(find(cond==ci));
            events.categories(ci).stimNum= stimNum(find(cond==ci));
            events.categories(ci).wlist= [];
            events.categories(ci).RT= [];
            events.categories(ci).RTons= [];
            events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
            %
            try
                events.categories(ci).stimName = stim_Name(find(cond==ci));
                events.categories(ci).stimList = stim_List(find(cond==ci));
                events.categories(ci).dur = dur(find(cond==ci));
                events.categories(ci).oneback = oneback(find(cond==ci));
            catch
            end
            
        end