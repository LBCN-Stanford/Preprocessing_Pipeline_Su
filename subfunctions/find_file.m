function [filename] = find_file(filepath,prefix,fix)
filename = [];
en = fullfile(filepath,prefix);
            match = [];
            S = dir(en);
            for k = 1:numel(S)
                N{k} = S(k).name;
                if contains(N{k}, fix)
                    match = [match, k];
                end
            end
            if ~isempty(match)
                filename = fullfile(filepath,N{match(end)});
            end