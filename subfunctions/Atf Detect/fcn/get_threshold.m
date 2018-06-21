function [v,th]=get_threshold(data,frame,overlap,type,param,input)
%     data: single channel raw data.
%   window: window length for rectangular window, or pre-defined window.
%  overlap: overlaping samples when calculating the variance.
%     type: choose which type of operator to use.
%    param: parameter used for the threshold.
%   Written by Su Liu
if nargin<6
    input=[];
elseif ~strcmp(type,'Manual') 
    input=[];
elseif input==0
    input=[];
end
if strcmp(type,'std')==1
    v=temp_variance(data,frame,overlap,2);
    m=median(v);
else
    v=temp_variance(data,frame,overlap);
            switch type
                case 'Mean'
                    m=mean(v);
                case 'Median'
                    m=median(v);
                %case 'std'
                    %m=std(v);
                case 'Manual'
                    if ~isempty(input)
                        th=input;
                        return;
                    end
            end
end
th=param*m;    
end