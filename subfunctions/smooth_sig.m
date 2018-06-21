function y=smooth_sig(signal,window,it,edge)
% Smooths  signal with sliding-average.
% If ends=0, the ends are zero. Faster.
% If ends=1, the ends are smoothed with progressively smaller smooths 
% the closer to the end. 

if nargin==2
    edge=0;
    it=1;
end
if nargin==3
    edge=0;
end

for k=1:it
    signal=sa(signal,window,edge);
   
end
y=signal;


function y=sa(Y,smoothwidth,edge)
w=round(smoothwidth);
SumPoints=sum(Y(1:w));
s=zeros(size(Y));
halfw=round(w/2);
L=length(Y);
for k=1:L-w
    s(k+halfw-1)=SumPoints;
    SumPoints=SumPoints-Y(k);
    SumPoints=SumPoints+Y(k+w);
end
s(k+halfw)=sum(Y(L-w+1:L));
y=s./w;
if edge==1
    startpoint=(smoothwidth + 1)/2;
    y(1)=(Y(1)+Y(2))./2;
    for k=2:startpoint
        y(k)=mean(Y(1:(2*k-1)));
        y(L-k+1)=mean(Y(L-2*k+2:L));
    end
    y(L)=(Y(L)+Y(L-1))./2;
end