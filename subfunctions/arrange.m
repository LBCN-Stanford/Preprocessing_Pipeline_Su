function new_sig = arrange(sig, handles)

Nt=length(handles.plot_cond);
try
    task = identify_task(path(handles.D{1}));
    fp = find_file(path(handles.D{1}),'Epoched_data*',task);
    savedparam = load(fp);
    if strcmpi(savedparam.plot_cond,'subcat')
        merge = 1;
    else
        merge = 0;
    end
catch
    merge = 0;
end
for N=1:length(sig)
    data = sig{N};
    cn = size(data,1);
    for i = 1:cn
        m = 1;
        dt=squeeze(data(i,:,:));
        try
            ex=savedparam.exclude{N}{i}(1,all(savedparam.exclude{N}{i}));
        catch
            ex = [];
        end
        conditionList = conditions(handles.D{N});
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
new_sig=beh_fp;