function rgb = map_color(channames)

cn = length(channames);
groupNo = length(unique(channames));
clr = brewermap(groupNo,'Set3')  ;
cnn = 1;
rgb = zeros(cn,3);
rgb(1,:) = clr(1,:);
for i = 2:cn
    name1 = join(regexp(string(channames{i-1}),'[a-z]','Match','ignorecase'),'');
    name2 = join(regexp(string(channames{i}),'[a-z]','Match','ignorecase'),'');
    if strcmp(name1,name2)
        rgb(i,:) = clr(cnn,:);
    else
        cnn=cnn+1;
        rgb(i,:) = clr(cnn,:);
    end
end
