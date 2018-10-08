function task = identify_task(filepath)
tasklist = {'faces' 'vtc' 'mmr' 'race' 'animal' 'hkat' 'appraisal' 'emotionf' 'emotiona'  'emotion' };
tasks = {'EmotionF' ,'category', 'MMR' ,'RACE_CAT' ,'Animal', 'RACE_CAT', 'EmotionA', 'EmotionF', 'EmotionA', 'EmotionF'};


try
    cont = lower(strsplit(filepath,'/'));
    for i=1:length(cont)
        t(i) = contains(cont{i},{'faces' 'vtc' 'mmr' 'race' 'appraisal' 'emotionf' 'emotiona'  'emotion' });
    end
    ft = find(t);
    ft = ft(1);
    taskdir = cont(ft);
catch
    so = load(filepath);
    try
        taskdir = strsplit(so.thePath.main,'\');    
    catch
    end
end
 try
    taskname = char(join(regexp(taskdir{end},'[a-z]','Match','ignorecase'),''));
    for i = 1:length(tasklist)
     if contains(lower(taskname),tasklist{i} )
         task = char(tasks{i});
         fprintf('-----------Task identified as %s----------\n',task);
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
     elseif ncond == 8
         task = 'EmotionA';
     else
         task = 'OTHER';
     end
 catch
       % warning('Could not identify the task. Will assign to OTHER');
       warning('Could not identify the task.')
        %task = 'OTHER';
        task = [];
 end

% try
%      sublist = strsplit(genpath(filepath),':')';
% for n = 1: length(sublist)
% match = find(contains(sublist(n),tasklist));
% end
%  catch
% 
%  end