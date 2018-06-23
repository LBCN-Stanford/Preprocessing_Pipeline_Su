function move_2dslice(elec_inuse, elecRgb, V,elecId, slice2d_axes, hm)

if isempty(elec_inuse) || isempty(V)
    return;
end

mri.vol = V;
mx=max(max(max(mri.vol)))*.7;
mn=min(min(min(mri.vol)));
sVol=size(mri.vol);
xyz = elec_inuse;

set(hm(1),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));
set(hm(2),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));
set(hm(3),'color',elecRgb(elecId,:),'markersize',30,'xdata',xyz(elecId,3),'ydata',xyz(elecId,2));
slice2d_axes(1);
imagesc(squeeze(mri.vol(:,xyz(elecId,1),:)),[mn mx]);
axis square;
set(gca,'xdir','reverse');
mxX=max(squeeze(mri.vol(xyz(elecId,1),:,:)),[],2);
mxY=max(squeeze(mri.vol(xyz(elecId,1),:,:)),[],1);
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


slice2d_axes(2);
imagesc(squeeze(mri.vol(xyz(elecId,2),:,:)),[mn mx]);
axis square;
mxX=max(squeeze(mri.vol(:,xyz(elecId,2),:)),[],2);
mxY=max(squeeze(mri.vol(:,xyz(elecId,2),:)),[],1);
limXa=max(intersect(1:(sVol(3)/2),find(mxX==0)));
limXb=min(intersect((sVol(3)/2:sVol(3)),find(mxX==0)));
limYa=max(intersect(1:(sVol(1)/2),find(mxY==0)));
limYb=min(intersect((sVol(1)/2:sVol(1)),find(mxY==0)));
%keep image square
tempMin=min([limXa limYa]);
tempMax=max([limXb limYb]);
if tempMin<tempMax
    axis([tempMin tempMax tempMin tempMax]);
end
set(gca,'xtick',[],'ytick',[]);

slice2d_axes(3);
imagesc(squeeze(mri.vol(:,:,xyz(elecId,3)))',[mn mx]);
axis square;
mxX=max(squeeze(mri.vol(:,:,xyz(elecId,3))),[],2);
mxY=max(squeeze(mri.vol(:,:,xyz(elecId,3))),[],1);
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
set(gca,'xtick',[],'ytick',[]);
