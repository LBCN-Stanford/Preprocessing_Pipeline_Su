function c_map = colormapping(spd)
figure;
h = imagesc(spd);
Cdata = h.CData;
%cmap = colormap(brewermap([],'*rdbu'));
cmap = colormap;%(jet(256));
% make it into a index image.
cmin = min(Cdata(:));
cmax = max(Cdata(:));
m = length(cmap);
index = fix((Cdata-cmin)/(cmax-cmin)*m)+1; %A
% Then to RGB
c_map = ind2rgb(index,cmap);
close gcf;