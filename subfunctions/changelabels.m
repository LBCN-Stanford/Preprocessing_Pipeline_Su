function label = changelabels(varargin)
%
%   This function finds the channels with the same labels that might cause
%   SPM error. The channel with the same name will be re-labeled as Name_b.
%   Please go back and inspect the naming if neccessary.
%   Input:      channel indicies and original labels.
%   Output:     new labels. If nothing is problematic then label would stay the
%   same.
%   -----------------------------------------
%   =^._.^=   Su Liu
%
%   suliu@standord.edu
%   -----------------------------------------


ind = varargin{1};
label = varargin{2};

if iscell(label) && length(label)>1
    if isnumeric(ind) && length(ind)~=length(label)
        error('Indices and values do not match');
    end
    
    if length(label)>1
        for i = 1:length(label)
            for j = (i+1):length(label)
                if strcmp(label{i}, label{j})
                    label{j} = strcat(label{j},'_b');
                    warning('Same labels found. Label for channel %d is renamed.',j);
                end
            end
        end
    end
    
end
