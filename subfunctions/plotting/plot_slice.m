function [slice2d_axes, hm] = plot_slice(elecMatrix, elecRgb, V,elecId)

if isempty(elecMatrix) || isempty(V)
    return;
end
mri.vol = V;
mx=max(max(max(mri.vol)))*.7;
mn=min(min(min(mri.vol)));
sVol=size(mri.vol);
xyz=zeros(size(elecMatrix));
xyz(:,1)=elecMatrix(:,2);
xyz(:,2)=elecMatrix(:,1);
xyz(:,3)=sVol(3)-elecMatrix(:,3);

hm=zeros(1,3);
colormap gray;
%subplot(131);
wdth=.28;
wDelt=.3;
xStart=.09;
yStart=.01;
ht=.4;
slice2d_axes(1) = axes('position',[xStart yStart wdth ht]);

imagesc(squeeze(mri.vol(:,xyz(elecId,1),:)),[mn mx]);
axis square;
set(gca,'xdir','reverse');
hold on;


% Plot electrode
hm(1)=plot(xyz(elecId,3),xyz(elecId,2),'r.');
set(hm(1),'color',elecRgb(elecId,:),'markersize',30);
%find image limits

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

%subplot(132);
slice2d_axes(2) = axes('position',[xStart+wDelt yStart wdth ht]);
imagesc(squeeze(mri.vol(xyz(elecId,2),:,:)),[mn mx]);
axis square;
hold on;


hm(2)=plot(xyz(elecId,3),xyz(elecId,1),'r.');
set(hm(2),'color',elecRgb(elecId,:),'markersize',30);
%find image limits
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

%subplot(133);
slice2d_axes(3) = axes('position',[xStart+wDelt*2 yStart wdth ht]);
imagesc(squeeze(mri.vol(:,:,xyz(elecId,3)))',[mn mx]);
axis square;
hold on;


hm(3)=plot(xyz(elecId,2),xyz(elecId,1),'r.');
set(hm(3),'color',elecRgb(elecId,:),'markersize',30);
%find image limits
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


hold off