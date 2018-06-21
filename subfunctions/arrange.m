function handles = arrange(sig, handles)

Nt=length(handles.plot_cond);

for N=1:length(sig)
        data = sig{N};
        cn = size(data,1);
        for i = 1:cn
            m = 1;
            dt=squeeze(data{N}(i,:,:));

                    ex = [];
conditionList = conditionList(handles.D{N});
                con=conditionList;
                con(ex)=[];
                
                dt(:,ex)=[];
            curr_id=false(Nt,size(dt,2));
            for k = handles.plot_cond
                %ex=[];
                %curr_cond=labs(plot_cond(k));
                curr_cond=handles.labels(k);
                
                if merge
                    if ~strcmp(curr_cond,'other')
                        if strcmp(curr_cond,'words')
                            curr_id(k,:)=strcmpi(con,curr_cond);
                        else
                            curr_id(k,:)=contains(string(con),strsplit(string(curr_cond)));
                        end
                    else
                        curr_id(k,:)=~sum(curr_id);
                    end
                else
       
                     curr_id(k,:)=strcmpi(con,curr_cond);
                end
                total_raw{N}{m}{i}=dt(:,curr_id(k,:));
                m=m+1;
            end
        end
end
    
    %%%%%%%%%merge multiple files (experiment sessions)%%%%%%%%%%
    
    if numel(total_raw)>1
        for nn=1:Nt
            for cc=1:cn
                currcond = [];
                for jj=1:numel(total_raw)
                    currcond=[currcond total_raw{jj}{nn}{cc}];
                end
                total_plot{nn}{cc}=currcond;
            end
        end
    else
        total_plot=total_raw{1};
    end
    beh_fp=total_plot;
    handles.signal_all=beh_fp;