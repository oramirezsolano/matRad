% matRad script
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2015 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc,clear,close all;

matRad_rc

% load patient data, i.e. ct, voi, cst

% load HEAD_AND_NECK
% load TG119.mat
% load PROSTATE.mat
% load LIVER.mat
load BOXPHANTOM.mat

% meta information for treatment plan

pln.radiationMode   = 'photons';     % either photons / protons / carbon
pln.machine         = 'Generic';

pln.numOfFractions  = 1;

% beam geometry settings
pln.propStf.bixelWidth      = 100; % [mm] / also corresponds to lateral spot spacing for particles
pln.propStf.gantryAngles    = 0; % [?]
pln.propStf.couchAngles     = 0; % [?]
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);

% dose calculation settings
pln.propDoseCalc.doseGrid.resolution.x = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 5; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 5; % [mm]

% optimization settings
pln.propOpt.optimizer       = 'IPOPT';
pln.propOpt.bioOptimization = 'none'; % none: physical optimization;             const_RBExD; constant RBE of 1.1;
                                      % LEMIV_effect: effect-based optimization; LEMIV_RBExD: optimization of RBE-weighted dose
pln.propOpt.runDAO          = false;  % 1/true: run DAO, 0/false: don't / will be ignored for particles
pln.propOpt.runSequencing   = false;  % 1/true: run sequencing, 0/false: don't / will be ignored for particles and also triggered by runDAO below

%% initial visualization and change objective function settings if desired

% generate steering file
stf = matRad_generateStf(ct,cst,pln);

%Find and use the central bixel only
centralRay = find(arrayfun(@(r) all(r.rayPos == [0 0 0]),stf.ray));
stf.ray = stf.ray(centralRay);
stf.numOfRays = 1;
stf.numOfBixelsPerRay = [1];
stf.totalNumOfBixels = 1;

%Compute the current SSD
stf = matRad_computeSSD(stf,ct);
fprintf('initial SSD = %f\n',stf.ray.SSD);

%Now move the isocenter to get the desired ssd of 1000mm.
% diff = stf.ray.SSD - 1000;
% stf.isoCenter(2) = stf.isoCenter(2) + diff;
% pln.propStf.isoCenter = stf.isoCenter;

%Compute and check the new SSD
stf = matRad_computeSSD(stf,ct);
fprintf('final SSD = %f\n',stf.ray.SSD);


%% dose calculation with ompMC and PencilBeam
dij_mc = matRad_calcPhotonDoseMC(ct,stf,pln,cst);
dij = matRad_calcPhotonDose(ct,stf,pln,cst);

resultGUI_mc = matRad_calcCubes(1,dij_mc);
resultGUI_pb = matRad_calcCubes(1,dij);


%%
% plot(dij.ctGrid.x(1,:),resultGUI.physicalDose(:,84,65));
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
plot(dij.ctGrid.z(1,:),(squeeze(resultGUI_pb.physicalDose(80,80,:))/max(resultGUI_pb.physicalDose(80,80,:))));
hold on
% plot(dij.ctGrid.x(1,:),resultGUI_mc.physicalDose(:,84,65));
plot(dij.ctGrid.z(1,:),(squeeze(resultGUI_mc.physicalDose(80,80,:))/max(resultGUI_mc.physicalDose(80,80,:))));

%% start gui for visualization of result
% matRadGUI