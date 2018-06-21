function Y = insertX(A,b,X)

% insert members into a vector
% by Ren, Oct 2016z

% Y = [];
% A0 = A;
% b0 = b;
% bb = find(b>length(A));
% if bb    
%     for i = 1:length(bb)
%         A(b(bb(i))) = X(bb(i));
%     end
% end
% b = b(b<=length(A0));

% inst = 0;
% bb = b;
% for i = 1:(length(A)+length(b))
%     if ismember(i-inst,bb)
%         Y(i) = X(find(b==i-inst));
%         bb = setdiff(bb,i-inst);
%         inst = inst+1;
%     else
%         Y(i) = A(i-inst);
%     end
% end

inst = 0;
for i = 1:(length(A)+length(b))
    if ismember(i,b)
        Y(i) = X(find(b==i));
        inst = inst+1;
    else
        Y(i) = A(i-inst);
    end
end
% Y
% 
% A = [4 8 7 10 2];
% b = [2 1 5 10 8];
% X = [-3 -2 -4 100 200];
