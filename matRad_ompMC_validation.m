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
load TG119.mat
% load PROSTATE.mat
%load LIVER.mat
% load BOXPHANTOM.mat

% meta information for treatment plan

pln.radiationMode   = 'photons';     % either photons / protons / carbon
pln.machine         = 'Generic';

pln.numOfFractions  = 1;

% beam geometry settings
pln.propStf.bixelWidth      = 50; % [mm] / also corresponds to lateral spot spacing for particles
pln.propStf.gantryAngles    = 90; % [?]
pln.propStf.couchAngles     = 90; % [?]
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
% pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1);
% pln.propStf.isoCenter(1,1)       = ct.x(1,floor(ct.cubeDim(1,1)/2));
% pln.propStf.isoCenter(1,2)       = ct.y(1,floor(ct.cubeDim(1,2)/2));
% pln.propStf.isoCenter(1,3)       = ct.z(1,floor(ct.cubeDim(1,3)/2));

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

%% generate steering file
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


%% dose calculation with ompMC
% dij = matRad_calcPhotonDoseMC(ct,stf,pln,cst,1e7); % nhist = 1e7
dij = matRad_calcPhotonDoseMC(ct,stf,pln,cst);

resultGUI = matRad_calcCubes(1,dij);

%% start gui for visualization of result
matRadGUI

