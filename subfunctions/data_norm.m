function data=data_norm(data,type)
% data: Input multi-channel data matrix. Column-wise.
% type: Choose the normalization method (0~5). Default value 4.
%    0: L0 normalization;
%    1: L1 normalization;
%    2: L2 normalization;
%    3: L infinity normalization;
%    4: Standard normalization;
%    5: Maxmin normalization.
%
% Written by Su Liu.
% suliu@stanford.edu

if nargin<2
    type=4;
end
for i=1:size(data,2)
    if type==0
        data(:,i)=data(:,i)./numel(find(data(:,i)~=0));
    elseif type==1
        data(:,i)=data(:,i)./(sum(abs(data(:,i)))+eps(0));
    elseif type==2
        data(:,i)=data(:,i)./(sqrt(sum(data(:,i).^2))+eps(0));
    elseif type==3
        data(:,i)=data(:,i)./max(data(:,i));
    elseif type==4
        data(:,i)=(data(:,i)-mean(data(:,i)))./std(data(:,i));
    elseif type==5
        data(:,i)=(data(:,i)-min(data(:,i)))./(max(data(:,i))-min(data(:,i))+eps(0));
    else
        error('Wrong configuration');
    end
end
end

