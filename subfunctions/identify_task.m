function task = identify_task(filepath)
tasklist = {'faces' 'vtc' 'mmr' 'race' 'animal' 'emotion' 'hkat'};
tasks = {'EmotionF' ,'category', 'MMR' ,'RACE_CAT' ,'Animal', 'EmotionF','RACE_CAT'};


try
    so = load(filepath);
    taskdir = strsplit(so.thePath.main,'\');
catch
    cont = lower(strsplit(filepath,'/'));
    for i=1:length(cont)
        t(i) = contains(cont{i},{'faces' 'vtc' 'mmr' 'race' 'emotion'});
    end
    taskdir = cont(t);
end
 try
    taskname = char(join(regexp(taskdir{end},'[a-z]','Match','ignorecase'),''));
    for i = 1:length(tasklist)
     if contains(lower(taskname),tasklist{i} )
         task = char(tasks{i});
         fprintf('-----------Identified as %s----------\n',task);
         return;
     end
    end
 catch
end
try
     [filename] = find_file(filepath,'eventsSODATA*.mat',[]);
     so = load(filename);     
catch
 end
 try
     ncond = length(so.events.categories);
     if ncond >= 20
         task = 'category';
     elseif ncond == 3
         task = 'RACE_ACT';
     elseif ncond == 5
         task = 'EmotionF';
     else
         task = 'OTHER';
     end
 catch
        warning('Could not identify the task. Will assign OTHER');
        task = 'OTHER';
 end

% try
%      sublist = strsplit(genpath(filepath),':')';
% for n = 1: length(sublist)
% match = find(contains(sublist(n),tasklist));
% end
%  catch
% 
%  end