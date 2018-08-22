% calc_beta.m

%Description: 
%This code calculates the extrinsic parameters (beta) for a camera image at a specific
%time using a nonlinear least squares fit solution. Use non collinear GCPs points across the beach. The output is the six
%variable extrinsic parameters. 

clear
close all
addpath(genpath('D:\Scordato_SSF_2018\Projects\SandwichBeachCam\extrinsic_calibration\gcp_surveys\2016-03-30_webcam_extrinsic_calibration'))
addpath(genpath('D:\Scordato_SSF_2018\Source_Code\UAV-Processing-Toolbox'))

%Inputs
%1. Break out gcp locations
%2. Pick GCP UV coordinates
%3. Calibration Image
%4. Known Flags 


%Outputs
%1. 
% break out gcp locations
load D:\Scordato_SSF_2018\Projects\SandwichBeachCam\extrinsic_calibration\gcp_surveys\2016-03-30_webcam_extrinsic_calibration\Local_GCP_mat\gcpSandwich2016_masterLocal

%load your picked gcp UV coordinates, determine which ones to use (try all,
%then 4 with lowest variance)
load D:\Scordato_SSF_2018\Projects\SandwichBeachCam\extrinsic_calibration\gcp_surveys\2016-03-30_webcam_extrinsic_calibration\UV_Pick_Variables\All_Vars_Workspace_Local

dtr = pi/180. ;
UTMxyCam = [376523.828 4625139.430];

%First guesses at beta
xyCam = [0 0];
zCam = 9;             % based on last data run
azTilt = [0 73] *pi/ 180;          % first guess
roll = 0 / 180*pi;
bs = [xyCam zCam azTilt roll];  % fullvector

%%
%Define your global variables
global globs


%Edit this depending on the unknown variables. '1' means the parameters is
%known, and '0' means the parameter is unknown. Variables: [ X Y Z Azimuth Tilt Roll].
knownFlags= [1 1 1 0 0 1] ;
beta0 = bs(find(~knownFlags));
knowns = bs(find(knownFlags));

globs.knownFlags= knownFlags;
globs.lcp= lcp;
globs.knowns = knowns;

%% Step 1. Load the image
calib_image = ('D:\Scordato_SSF_2018\Projects\SandwichBeachCam\images\2016_average\March30-April3\20160330T132520L.jpg');


% read the first frame and display.  Do a manual geometry on it if needed.
I = imread(calib_image);
[NV, NU, NC] = size(I);
Ig = rgb2gray(I);           % for later sampling.

% subtract camera location
for i = 1:length(gcp)
    gcp(i).xo = gcp(i).x - UTMxyCam(1);
    gcp(i).yo = gcp(i).y - UTMxyCam(2);
end


for which_list= 1: 12



%Define the GCP combinations you want to test 
switch which_list
    case 1
        gcpList= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
       
    case 2
        gcpList= [1 3 7 10];
        
    case 3
        gcpList=[1 3 7 9 10];
        
    case 4
        gcpList= [2 4 6];
        
    case 5
        gcpList= [1 3 4 6];
    case 6
        gcpList= [2 7 8 9]
    case 7 
        gcpList= [1 3 4]
    case 8
        gcpList= [2 9 10]
    case 9
        gcpList= [1 2 3 6]
    case 10
        gcpList= [5 6 8 9]
    case 11
        gcpList= [1 3 4]
    case 12 
        gcpList= [1 8 3 6]
end

nGcps = length(gcpList);
x = [gcp(gcpList).xo];
y = [gcp(gcpList).yo];
z = [gcp(gcpList).z];
xyz = [x' y' z'];% look at location in camera frame

UV = [ mean(Uall(gcpList,:),2), mean(Vall(gcpList, :),2) ];


[ beta, R,J,COVB,MSE] = nlinfit(xyz,[UV(:,1); UV(:,2)],'findUVnDOF',beta0)

hold on
plot(UV(:,1),UV(:,2),'g*')
UV2 = findUVnDOF(beta,xyz,globs);
UV2 = reshape(UV2,[],2);
plot(UV2(:,1),UV2(:,2),'ro');

beta6DOF = nan(1,6);
beta6DOF(find(globs.knownFlags)) = globs.knowns;
beta6DOF(find(~globs.knownFlags)) = beta 

betas(which_list, :)= beta6DOF

% %Calculate the error between UV and UV2
uvdel2= ((UV)- (UV2)).^2
uvdel(which_list, :)= sqrt(uvdel2(1).^2 + uvdel2(2).^2)


end


