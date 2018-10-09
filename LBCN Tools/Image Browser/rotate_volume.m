function out = rotate_volume(volume, angle, xyz)

switch xyz
    case 1
        out = imrotate(volume, angle,'bilinear','crop' );
    case 2
        volume = permute(volume,[2 1 3]);
        volume = imrotate(volume, angle,'bilinear','crop' );
        out = permute(volume,[2 1 3]);
    case 3
        volume = permute(volume,[3 2 1]);
        volume = imrotate(volume, angle,'bilinear','crop' );
        out = permute(volume,[3 2 1]);
end