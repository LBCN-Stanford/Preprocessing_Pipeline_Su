function [r,v2]= rot_e(p1,p2)
%   Computes the rotation direction and angles for each electrode
%   P1 is the N by 3 coordinates of the electrode;
%   P2 is the set of nearest corresponding points on the outer surface of a template brain
%   -----------------------------------------
%   =^._.^=     Su Liu
%
%   suliu@standord.edu
%   -----------------------------------------
for i = 1:size(p1,1)
    if abs(p1(i,1)) < 7 && p1(i,3) > -15
        p1(i,1) = p1(i ,1)+50*sign(p1(i,1));% to correct some of the medial electrodes
    end
end
v2 = (p1-p2)./norm(p1-p2);
v1 = [0 0 1];
v1=repmat(v1,size(p1,1),1);
r = zeros(size(p1,1),4);
for i = 1:size(p1,1)
    r(i,:) = vrrotvec(v1(i,:),v2(i,:)) ;
end
%   First three elements specify the rotation axis, the last element
%   defines the angle of rotation.


%h = hgtransform;
%m = makehgtform('axisrotate', v2, r);%v2 is the normal of the target plane
%set(h, 'Matrix', m);
%rotate(hSurface,v2,r)