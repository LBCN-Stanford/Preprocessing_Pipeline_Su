function progress(i,ttl,n,changeline, text)
tar = floor(ttl/n)*(1:n);
if any(ismember(i,tar))
    if changeline
    disp('.');
    else
        fprintf('.');
    end
end
end