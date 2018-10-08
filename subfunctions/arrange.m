function new_sig = arrange(sig, handles, D, plot_cond, exclude,labels,conditionList)
merge = 0;
if ~isempty(handles)
    plot_cond = handles.plot_cond;
    D = handles.D;
    labels = handles.labels;
    try
        task = identify_task(path(handles.D{1}));
        fp = find_file(path(handles.D{1}),'Epoched_data*',task);
        savedparam = load(fp);
        if strcmpi(savedparam.plot_cond,'subcat')
            merge = 1;
        end
        
    catch
    end
elseif iscell(plot_cond)
        if any(strcmp(plot_cond,'subcat'))
            labels = [{'faces'} {'bodies'} {'buildings & scenes'} {'numbers'} ...
                {'words'} {'logos & shapes'} {'other'}];
            plot_cond = [5 4 1 2 3 6];
            merge = 1;
        else
            labels = condlist(D{1});
            for i = length(plot_cond)
                condid(i) = find(strcmpi(labels,plot_cond{i}));
            end
            plot_cond = condid;
        end
else
    if nargin<6 || isempty(labels)
        labels = condlist(D{1});
    end
end

Nt = length(plot_cond);
if ~iscell(sig)
    s{1}=sig;
    sig=s;
end

    
for N=1:length(sig)
    if isempty(sig{N}) && ~isempty(D)
        sig{N} = D{N}(:,:,:);
    end
    data = sig{N};
    cn = size(data,1);
    for i = 1:cn
        m = 1;
        dt=squeeze(data(i,:,:));
        if nargin<4 || isempty(exclude)
            try
                ex=savedparam.exclude{N}{i}(1,all(savedparam.exclude{N}{i}));
            catch
                ex = [];
            end
        else
            try
            ex = exclude{N}{i}(1,all(exclude{N}{i}));
            catch
                ex = [];
            end
        end
        if nargin < 7 || isempty(conditionList)
            condList = conditions(D{N});
        else
            condList = conditionList{N};
        end
        con=condList;
        con(ex)=[];
        
        dt(:,ex)=[];
        curr_id=false(Nt,size(dt,2));
        
        for k = plot_cond
            %ex=[];
            %curr_cond=labs(plot_cond(k));
            curr_cond=labels(k);
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