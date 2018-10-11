function move_2dslice_b(elecMatrix, elecRgb, V,elecId, slice2d_axes)

if isempty(elecMatrix) || isempty(V)
    return;
end

mri.vol = V;
mx=max(max(max(mri.vol)))*.7;
mn=min(min(min(mri.vol)));
sVol=size(mri.vol);
%xyz = round(elecMatrix);

xyz(:,1)=elecMatrix(:,2);
xyz(:,2)=elecMatrix(:,1);
xyz(:,3)=sVol(3)-elecMatrix(:,3);

% set(hm(1),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));hold on
% set(hm(2),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));hold on
% set(hm(3),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));hold on
axes(slice2d_axes(1))
imagesc(squeeze(mri.vol(:,xyz(elecId,1),:)),[mn mx]);
hold on
plot(xyz(elecId,3),xyz(elecId,2),'.','color',elecRgb(elecId,:),'markersize',30);
axis square;
set(gca,'xdir','reverse');
mxX=max(squeeze(mri.vol(:,xyz(elecId,1),:)),[],2);
mxY=max(squeeze(mri.vol(:,xyz(elecId,1),:)),[],1);
limXa=max(intersect(1:(sVol(3)/2),find(mxX==0)));
limXb=min(intersect((sVol(3)/2:sVol(3)),find(mxX==0)));
limYa=max(intersect(1:(sVol(2)/2),find(mxY==0)));
limYb=min(intersect((sVol(2)/2:sVol(2)),find(mxY==0)));
%keep image square
tempMin=min([limXa limYa]);
tempMax=max([limXb limYb]);
if tempMin<tempMax
    axis([tempMin tempMax tempMin tempMax]);
end
set(gca,'xtick',[],'ytick',[],'xdir','reverse');


axes(slice2d_axes(2))
imagesc(squeeze(mri.vol(xyz(elecId,2),:,:)),[mn mx]);
hold on
plot(xyz(elecId,3),xyz(elecId,1),'.','color',elecRgb(elecId,:),'markersize',30);
axis square;
mxX=max(squeeze(mri.vol(xyz(elecId,2),:,:)),[],2);
mxY=max(squeeze(mri.vol(xyz(elecId,2),:,:)),[],1);
limXa=max(intersect(1:(sVol(3)/2),find(mxX==0)));
limXb=min(intersect((sVol(3)/2:sVol(3)),find(mxX==0)));
limYa=max(intersect(1:(sVol(1)/2),find(mxY==0)));
limYb=min(intersect((sVol(1)/2:sVol(1)),find(mxY==0)));
%keep image square
centershift = sVol(3)/2-((limXb-limXa)/2+limXa);
if limYa-(limYb-limYa) < limYb+(limYb-limYa)
axis([limYa-(limYb-limYa)*0.05 limYb+(limYb-limYa)*0.05...
    limYa-(limYb-limYa)*0.05-centershift limYb+(limYb-limYa)*0.05-centershift ])
end
% tempMin=min([limXa limYa]);
% tempMax=max([limXb limYb]);
% if tempMin<tempMax
%     axis([tempMin tempMax tempMin tempMax]);
% end
set(gca,'xtick',[],'ytick',[]);


axes(slice2d_axes(3))
imagesc(squeeze(mri.vol(:,:,xyz(elecId,3)))',[mn mx]);
hold on
plot(xyz(elecId,2),xyz(elecId,1),'.','color',elecRgb(elecId,:),'markersize',30);
axis square;
mxX=max(squeeze(mri.vol(:,:,xyz(elecId,3))),[],2);
mxY=max(squeeze(mri.vol(:,:,xyz(elecId,3))),[],1);
limXa=max(intersect(1:(sVol(3)/2),find(mxX==0)));
limXb=min(intersect((sVol(3)/2:sVol(3)),find(mxX==0)));
limYa=max(intersect(1:(sVol(2)/2),find(mxY==0)));
limYb=min(intersect((sVol(2)/2:sVol(2)),find(mxY==0)));
%keep image square
centershift = sVol(3)/2-((limYb-limYa)/2+limYa);
if limXa-(limXb-limXa) < limXb+(limXb-limXa)
axis([limXa-(limXb-limXa)*0.07 limXb+(limXb-limXa)*0.07...
    limXa-(limXb-limXa)*0.07-centershift limXb+(limXb-limXa)*0.07-centershift ])
end



% tempMin=min([limXa limYa]);
% tempMax=max([limXb limYb]);
% if tempMin<tempMax
%     axis([tempMin tempMax tempMin tempMax]);
% end

hold off
set(gca,'xtick',[],'ytick',[]);
