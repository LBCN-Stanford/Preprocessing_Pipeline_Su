function [count,idx]=zerocross_count(data)
%Computes the zero-crossing number
%Written by Su Liu
s = size(data);    % size of matrix v
l = s(1);       % Number of row of matrix v
for m=1:l
   x = data(m,:);
%    disp(' ')
%    disp(['New input vector x: ', num2str(x)])
%    disp(' ')
%    num_samples = length(x);
%    count       = 0;
%    for n=2:num_samples
%        if((x(n) * x(n-1)) <= 0)
%            count = count + 1;
%        end
%    end
%    disp(['Method of product, count = ', num2str(count)])
   
   % Method, eliminating the defects of precedent code   
   x_sign= sign(x);             % Negative: -1, Zero: 0, Positive 1
   index_0  = x_sign == 0;   % Index of elements == 0
   x_sign(index_0) = 1;                   % Set elements == 0 to 1
   x_sign_diff = diff(x_sign);        % Change of sign detection
   idx=find(x_sign_diff ~= 0);
   count = length(find(x_sign_diff ~= 0)); % Not == 0 means a jump of sign  
end
end


