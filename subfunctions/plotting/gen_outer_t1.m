
V=smooth3(V,'gaussian',3);
volume=V;
Gaussian = fspecial('gaussian',[2 2],1);
image_f=zeros(256,256,256);
for slice=1:256
    temp = double(reshape(volume(:,:,slice),256,256));
    image_f(:,:,slice) = conv2(temp,Gaussian,'same');
end
image2=zeros(size(image_f));
image2(image_f<=25)=0;
image2(image_f>25)=255;
se=strel('ball',se_diameter,se_diameter);
BW2=imclose(image2,se);
thresh = max(BW2(:))/2;
i=find(BW2<=thresh);
BW2(i)=0;
i=find(BW2>thresh);
BW2(i)=255;
outer=isosurface(J,0.8);
ph=patch(outer);
%patch(outer);
h=reducepatch(ph,0.2);
[v,f]=smoothMesh(h.vertices, h.faces, 25);