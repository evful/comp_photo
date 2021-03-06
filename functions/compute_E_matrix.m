% function E = compute_E_matrix( points1, points2, K1, K2 );
%
% Method:   Calculate the E matrix between two views from
%           point correspondences: points2^T * E * points1 = 0
%           we use the normalize 8-point algorithm and 
%           enforce the constraint that the three singular 
%           values are: a,a,0. The data will be normalized here. 
%           Finally we will check how good the epipolar constraints:
%           points2^T * E * points1 = 0 are fullfilled.
% 
%           Requires that the number of cameras is C=2.
% 
% Input:    points2d is a 3xNxC array storing the image points.
%
%           K is a 3x3xC array storing the internal calibration matrix for
%           each camera.
%
% Output:   E is a 3x3 matrix with the singular values (a,a,0).

function E = compute_E_matrix( points2d, K )

%% Create E
[h, w, cameras] = size(points2d);

points2d_norm = zeros(h, w, cameras);
for c = 1 : cameras
    points2d_norm(:,:,c) = inv(K(:,:,c)) * points2d(:,:,c);
end

N = compute_normalization_matrices(points2d_norm);
points2d_norm(:,:,1) = N(:,:,1) * points2d_norm(:,:,1);
points2d_norm(:,:,2) = N(:,:,2) * points2d_norm(:,:,2);

Y = zeros(w,9);

Y(:,1) = points2d_norm(1,:,2) .* points2d_norm(1,:,1);
Y(:,2) = points2d_norm(1,:,2) .* points2d_norm(2,:,1);
Y(:,3) = points2d_norm(1,:,2);

Y(:,4) = points2d_norm(2,:,2) .* points2d_norm(1,:,1);
Y(:,5) = points2d_norm(2,:,2) .* points2d_norm(2,:,1);
Y(:,6) = points2d_norm(2,:,2);

Y(:,7) = points2d_norm(1,:,1);
Y(:,8) = points2d_norm(2,:,1);
Y(:,9) = 1;

[~, ~, V] = svd(Y);

F = zeros(3,3);
F(1,:) = V(1:3, end);
F(2,:) = V(4:6, end);
F(3,:) = V(7:9, end);

E = N(:,:,2)' * F * N(:,:,1);

[U, S, V] = svd(E);

S_avg = (S(1,1)+S(2,2))/2;
S(1,1) = S_avg;
S(2,2) = S_avg;

E = U*S*V';

% for p = 1 : w
%     if points2d_norm(:,p,2)' * E * points2d_norm(:,p,1) > 2.72^-10
%         msg = 'points2^T * E * points1 != 0, E not correct';
%         error(msg);
%     end
% end



