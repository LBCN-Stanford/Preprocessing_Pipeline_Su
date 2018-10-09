function show_ct_skull(filename)
%   Load nii format CT image and show skull surface in 3D
%   Su Liu
%   suliu@stanford.edu
% ---------------------------
if ~isa(filename,'string')
    volume = filename;
else
    volume = spm_read_vols(spm_vol(filename));
end
    
    

%th1 = 0;
%th2 = 0.05;
vol = volume;
vol =  vol/max( vol(:));
%J = imadjust(vol(:),[ th1*max(vol(:));  th2*max(vol(:))],[0; 1]);
%vol_r=reshape(J,size(vol));
J_v = imadjust(vol(:));
v_v = reshape(J_v,size(vol));
V = zeros(size(v_v));
for i=1:size(v_v,3)
    vnn = imbinarize(v_v(:,:,i),0.3);
    V(:,:,i) = vnn;
end
fv = isosurface(V);
h = patch('faces',fv.faces,'vertices',fv.vertices);
ct = reducepatch(h,0.2);
[v2, faces] = smoothMesh( ct.vertices,  ct.faces, 1);
ct.vertices = v2; 
ct.faces = faces;
delete(h);
patch('faces', ct.faces,'vertices', ct.vertices,...
    'edgecolor','none','facecolor',[0.75 0.75 0.85],...
    'facealpha',0.3,'BackfaceLighting', 'lit', ...
    'AmbientStrength',  0.5, ...
    'DiffuseStrength',  0.2, ...
    'SpecularStrength', 0.2, ...
    'SpecularExponent', 1, ...
    'SpecularColorReflectance', 0.6,'facelighting','flat');
axis vis3d
view(3); 
%rotate3d;
set(gca,'CameraViewAngle',5);
set(gca,'color',[1 1 1]);
%camlight(0,70); 
daspect([1,1,1]);

function [v2, faces] = smoothMesh(vertices, faces, varargin)
%SMOOTHMESH Smooth mesh by replacing each vertex by the average of its neighbors 

nIter = 1;
if ~isempty(varargin)
    nIter = varargin{1};
end
adj = meshAdjacencyMatrix(faces);
nv = size(adj, 1);
adj = adj + speye(nv);
w = spdiags(full(sum(adj, 2).^(-1)), 0, nv, nv);
adj = w * adj;

v2 = vertices;
for k = 1:nIter
    v2 = adj * v2;
end