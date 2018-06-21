function y=temp_variance(data,frame,overlap,type)
%Computes the temporal variance of signal using moving window. 
%Written by Su Liu
if nargin<4
    type=1;
end
if isscalar(frame)
    winlength = frame;
    window = ones(winlength,1);
elseif isvector(frame)
    window = frame;
    winlength = length(frame);
end

%x = [zeros(ceil((winlength*overlap+1)/2)-1,1); data(:); zeros(floor((winlength*overlap+1)/2),1)];
lx=length(data);
index = spdiags(repmat((1:lx)',[1 winlength]),0:-(winlength-overlap):-lx+winlength);
window = repmat(window,[1 size(index,2)]);
switch type
    case 1
        y(:,1) = var((window.*data(index)));
    case 2
        y(:,1) = std((window.*data(index)));
    case 3
        y(:,1) = mean((window.*data(index)));
end
end