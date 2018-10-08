function [task,name] = get_info(filepath)
try
    if exist(filepath,'file') == 2
        so = load(filepath);
        sodir = filepath;
    else
        sublist = strsplit(genpath(filepath),':')';
        for i=1:length(sublist)
            sodir = find_file(sublist{i},'sodata*.mat',[]);
            if isempty(sodir)
                sodir = find_file(sublist{i},'','Formatted');
            end
            if ~isempty(sodir)
                break;
            end
        end
        so = load(sodir);
    end
    try
        task = identify_task(sodir);
    catch
        task = [];
    end
    try
        nsplit = strfind(so.subID,'_');
        name = so.subID(1:nsplit(end));
    catch
        name = [];
    end
    
catch
    task = [];
    name = [];
end
