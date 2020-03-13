%% Example: Photon Treatment Plan using VMC++ dose calculation
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2017 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% In this example we will show 
% (i) how to load patient data into matRad
% (ii) how to setup a photon dose calculation based on the VMC++ Monte Carlo algorithm 
% (iii) how to inversely optimize the beamlet intensities directly from command window in MATLAB. 
% (iv) how to visualize the result

%% Patient Data Import
% Let's begin with a clear Matlab environment and import the boxphantom
% into your workspace. 
clc,clear,close all;

% file = 'HEAD_AND_NECK.mat';
% file = 'TG119.mat';
% file = 'PROSTATE.mat';
% file = 'LIVER.mat';
file = 'BOXPHANTOM.mat';
load(file);

%% Treatment Plan
% The next step is to define your treatment plan labeled as 'pln'. This 
% structure requires input from the treatment planner and defines the most
% important cornerstones of your treatment plan.

pln.radiationMode  = 'photons';  
pln.machine        = 'Generic';
pln.numOfFractions = 30;
pln.propOpt.bioOptimization = 'none';    
% pln.propStf.gantryAngles    = [0:72:359]; % [?]
% pln.propStf.couchAngles     = [0 0 0 0 0]; % [?]
pln.propStf.gantryAngles    = [0]; % [?]
pln.propStf.couchAngles     = [0]; % [?]
pln.propStf.bixelWidth      = 5;
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
pln.propOpt.runSequencing   = 0;
pln.propOpt.runDAO          = 0;

%% Generate Beam Geometry STF
stf = matRad_generateStf(ct,cst,pln);

%% To print the results
dij = matRad_calcPhotonDoseMCRes(file,ct,stf,pln,cst);

%% Dose Calculation
% Calculate dose influence matrix for unit pencil beam intensities using 
% a Monte Carlo algorithm
% dij = matRad_calcPhotonDoseMC(ct,stf,pln,cst);
dij_mc = matRad_calcPhotonDoseMC(ct,stf,pln,cst);
dij = matRad_calcPhotonDose(ct,stf,pln,cst);

% a version of matRad_calcPhotonDoseMC to print the egsphant and the
% beamlet file
% dij = matRad_calcPhotonDoseMCRes(file,ct,stf,pln,cst);

% Not in use (to create a beamlet file)
% matRad_beamletsFileCreatorMC(file,stf,pln)

%% Inverse Optimization for IMRT
% resultGUI = matRad_fluenceOptimization(dij,cst,pln);
resultGUI_mc = matRad_fluenceOptimization(dij_mc,cst,pln);
resultGUI_pb = matRad_fluenceOptimization(dij,cst,pln);

%%
plot(dij.ctGrid.x(1,:),(squeeze(resultGUI_pb.physicalDose(80,80,:))/max(resultGUI_pb.physicalDose(80,80,:))));
hold on
% plot(dij.ctGrid.x(1,:),resultGUI_mc.physicalDose(:,84,65));
plot(dij.ctGrid.x(1,:),(squeeze(resultGUI_mc.physicalDose(80,80,:))/max(resultGUI_mc.physicalDose(80,80,:))));

%%
% plot(dij.ctGrid.x(1,:),resultGUI.physicalDose(:,84,65));
plot(dij.ctGrid.y(1,:),(resultGUI_pb.physicalDose(:,80,80)/max(resultGUI_pb.physicalDose(:,80,80))));
hold on
% plot(dij.ctGrid.x(1,:),resultGUI_mc.physicalDose(:,84,65));
plot(dij.ctGrid.y(1,:),(resultGUI_mc.physicalDose(:,80,80)/max(resultGUI_mc.physicalDose(:,80,80))));

%%
% matRadGUI;

%% Plot the Resulting Dose Slice
% Just let's plot the transversal iso-center dose slice
% slice = round(pln.propStf.isoCenter(1,3)./ct.resolution.z);
% figure,
% imagesc(resultGUI.physicalDose(:,:,slice)),colorbar, colormap(jet)

%%
% Exemplary, we show how to obtain the dose in the target and plot the histogram
% ixTarget     = cst{2,4}{1};
% doseInTarget = resultGUI.physicalDose(ixTarget);
% figure
% histogram(doseInTarget);
% title('dose in target'),xlabel('[Gy]'),ylabel('#');