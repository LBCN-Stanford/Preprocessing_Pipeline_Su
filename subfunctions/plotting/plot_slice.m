function [slice2d_axes] = plot_slice(elecMatrix, elecRgb, V,elecId,fig)

if isempty(elecMatrix) || isempty(V)
    slice2d_axes = [];
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
colormap gray;close(gcf);
%subplot(131);
wdth=.33;
wDelt=2.3;
xStart=.09;
yStart=.09;
ht=.44;
fs=get(fig,'position');fs(4)=fs(4)*2;
slice2d_axes(1) = uiaxes('parent',fig,'position',fs.*[xStart yStart wdth ht]);

imshow(squeeze(mri.vol(:,xyz(elecId,1),:)),[mn mx],'parent',slice2d_axes(1));
axis(slice2d_axes(1),'square');
set(slice2d_axes(1),'xdir','reverse','color',[0.98 0.98 0.98],'BackgroundColor',[0.98 0.98 0.98]);

set(slice2d_axes(1),'nextplot','add');

% Plot electrode
hm(1)=plot(slice2d_axes(1),xyz(elecId,3),xyz(elecId,2),'r.');
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
    axis(slice2d_axes(1),[tempMin tempMax tempMin tempMax]);
end
set(slice2d_axes(1),'xtick',[],'ytick',[],'xdir','reverse','color',[0.98 0.98 0.98],'BackgroundColor',[0.98 0.98 0.98]);

%subplot(132);uiaxes('parent',fig,'position',fs.*[xStart yStart wdth ht]);
slice2d_axes(2) = uiaxes(fig,'position',fs.*[xStart+wDelt yStart wdth ht]);
imshow(squeeze(mri.vol(xyz(elecId,2),:,:)),[mn mx],'parent',slice2d_axes(2));
axis(slice2d_axes(2),'square');
set(slice2d_axes(2),'nextplot','add');


hm(2)=plot(slice2d_axes(2),xyz(elecId,3),xyz(elecId,1),'r.');
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
    axis(slice2d_axes(2),[tempMin tempMax tempMin tempMax]);
end
set(slice2d_axes(2),'xtick',[],'ytick',[],'color',[0.98 0.98 0.98],'BackgroundColor',[0.98 0.98 0.98]);

%subplot(133);
slice2d_axes(3) = uiaxes(fig,'position',fs.*[xStart+wDelt*2 yStart wdth ht]);
% imagesc(squeeze(mri.vol(:,:,xyz(elecId,3)))',[mn mx]);
% axis square;
% hold on;
imshow(squeeze(mri.vol(:,:,xyz(elecId,3)))',[mn mx],'parent',slice2d_axes(3));
axis(slice2d_axes(3),'square');
set(slice2d_axes(3),'nextplot','add','color',[0.98 0.98 0.98]);

hm(3)=plot(slice2d_axes(3),xyz(elecId,2),xyz(elecId,1),'r.');
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
    axis(slice2d_axes(3),[tempMin tempMax tempMin tempMax]);
end
%set(slice2d_axes(3),'xtick',[],'ytick',[],'color',[0.98 0.98 0.98],'BackgroundColor',[0.98 0.98 0.98]);

set(slice2d_axes(3),'nextplot','replace');
set(slice2d_axes(3),'xtick',[],'ytick',[],'color',[0.98 0.98 0.98],'BackgroundColor',[0.98 0.98 0.98]);