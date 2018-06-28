function min_ind = find_most_similar(target_word, candidate_list, ignCase)
if nargin < 3
    ignCase = 1;
end
distance = inf(1,length(candidate_list));

if iscell(target_word)
    target_word = target_word{1};
end
if iscell(candidate_list)
    candidate_list = string(candidate_list);
end
target_word = char(target_word);
if ignCase
    target_word = lower(target_word);
    candidate_list = lower(candidate_list);
end

    for i = 1:length(candidate_list)
            distance(i) = EditDist(char(target_word),char(candidate_list(i)));
    end

[~,min_ind] = min(distance);