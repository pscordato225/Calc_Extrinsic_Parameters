% Sandwich_Video_Setup_crs.m
%This code is written for picking GCPs in a calibration image. You can use these
%picked GCPs to calculate unknown extrinsic parameters using a least
%squares fit solution. 



%Inputs: 
%1. calib_image= Image with ground control points in frame
%2. 'gcp' file- Easting and Northing GCP points file 


%Output: uv_picked (GCP UV locations)


clear
close all

addpath(genpath('D:\Scordato_SSF_2018\Projects\SandwichBeachCam\extrinsic_calibration\gcp_surveys\2016-03-30_webcam_extrinsic_calibration\Local_GCP_mat'))

dtr = pi/180.
UTMxyCam = [376523.828 4625139.430];

%% Step 1. Load the image
calib_image = 'D:\Scordato_SSF_2018\Projects\SandwichBeachCam\images\2017\c1\2017_master\20180103T170149L.jpg'
% read the first frame and display.  Do a manual geometry on it if needed.
I = imread(calib_image);
[NV, NU, NC] = size(I);
Ig = rgb2gray(I);           % for later sampling.
%% Step 2. Load all of the GCPs
load D:\Scordato_SSF_2018\Projects\SandwichBeachCam\extrinsic_calibration\gcp_surveys\20180103_Objects_Extrinsic_Calib\20180103_gcp_file
% subtract camera location
for i = 1:length(gcp)
   gcp(i).xo = gcp(i).x - UTMxyCam(1);
   gcp(i).yo = gcp(i).y - UTMxyCam(2);
end

% break out gcp locations for ALL gcps for now
nGcps = length(gcp);
x = [gcp((1:nGcps)).xo];
y = [gcp((1:nGcps)).yo];
z = [gcp((1:nGcps)).z];
xyz = [x' y' z'];

% digitize all of the GCPs five times
% make UV arrays to hold the digitized results
Uall = zeros(nGcps,5);
Vall = zeros(nGcps,5);

for j=1:4
   % digitize the gcps and find best fit geometry
   figure(1); clf
   imagesc(I); axis image;
   disp(['computing geometry using ' num2str(nGcps) ' control points'])
   zoom reset
   for i = 1: nGcps
      disp(['Zoom in to see ' gcp(i).name ' then press Enter'])
      tit = title(['Zoom in to see ']) gcp(i).name ' then press Enter']);
      zoom on;
      pause
      zoom off;
      disp(['Digitize ' gcp(i).name])
      tit = title(['Now digitize ' gcp(i).name ]);
      xy=ginput(1);
      Uall(i,j) = xy(1);
      Vall(i,j) = xy(2);
      delete(tit)
      zoom out
   end
end

save('uv_picked','Uall','Vall')