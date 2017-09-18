
% Method:   Generate one image out of multiple images. All images are from
%           a camera with the same (!) center of projection. All the images 
%           are registered to one reference view.

clear all                   % Remove all old variables
close all                   % Close all figures
clc                         % Clear the command window
addpath( genpath( '../' ) );% Add paths to all subdirectories of the parent directory

LOAD_DATA           = true;
REFERENCE_VIEW      = 3;
CAMERAS             = 3;
image_names_file    = 'C:/git_repos/comp_photo/images/names_images_kthsmall.txt';
name_panorama       = 'C:/git_repos/comp_photo/images/panorama_image.jpg';
points2d_file       = 'C:/git_repos/comp_photo/data/data_kth.mat';

[images, name_loaded_images] = load_images_grey( image_names_file, CAMERAS );

% Load the clicked points if they have been saved,
% or click some new points:
if LOAD_DATA
    load( points2d_file );
else
    points2d = click_multi_view( images ); %, C, data, 0 ); % for clicking and displaying data
    save( points2d_file, 'points2d' );
end


%% Compute homographies
% Determine all homographies to a reference view. We have:
% point in REFERENCE_VIEW = homographies(:,:,c) * point in image c.
% Remember, you have to set homographies{REFERENCE_VIEW} as well.
homographies = zeros(3,3,CAMERAS); 

%-------------------------
% TODO: FILL IN THIS PART
[h w] = find(isnan(points2d(:,:,1)))
h = h(1);
w = w(1);
homographies(:,:,1) = compute_homography(points2d(1:3,1:w-1,1), points2d(1:3,1:w-1,3));
homographies(:,:,2) = compute_homography(points2d(1:3,w:end,2), points2d(1:3,w:end,3));
%homographies(:,:,3) = compute_homography([points2d(1:3,1:w-1,1) points2d(1:3,w:end,2)], points2d(:,:,3));

for c=1:CAMERAS
    points_ref = points2d(:,:,REFERENCE_VIEW);
    points_c   = points2d(:,:,c);
    
    homographies_test(:,:,c) = compute_homography( points_ref, points_c );
end


for c = 1:CAMERAS
    
    [error_mean error_max] = check_error_homographies( ...
      homographies(:,:,c), points2d(:,:,c), points2d(:,:,REFERENCE_VIEW) );
 
    fprintf( 'Between view %d and ref. view; ', c );
    fprintf( 'average error: %5.2f; maximum error: %5.2f \n', error_mean, error_max );
end


%% Generate, draw and save panorama

panorama_image = generate_panorama( images, homographies );

figure;  
show_image_grey( panorama_image );
save_image_grey( name_panorama, panorama_image );
