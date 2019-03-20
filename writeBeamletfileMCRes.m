function writeBeamletfileMCRes(file,nBeams,nBixels,beamSource,iBeam,bixelCorner,bixelSide1,bixelSide2)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad ompMC monte carlo beamlet file creator
% 
% call
%   writeBeamletfileMCRes(file,ompMCsource.nBeams,ompMCsource.nBixels,beamSource,ompMCsource.iBeam,bixelCorner,bixelSide1,bixelSide2);
% 
% input
%   file:           variable with the .mat file's name
%   nBeams:         total number of beams
%   nBixels:        total number of bixels/beamlets
%   beamSource:     x,y,z coordinates of the source for each bixel
%   iBeam:          number os beam por each bixel (index)
%   bixelCorner:    x,y,z coordinates of one corner for each bixel
%   bixelSide1 & 2: x,y,z coordinates of one corner for each bixel
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputname = strtok(file,'.mat');
ext = '.beamlet';

fileID = fopen(strcat(outputname,ext),'w');

% writing the geometry in a .beamlet file ext.
fprintf(fileID, '%d %d ', nBeams, nBixels);
fprintf(fileID, '\n');
for i = 1:nBeams
    fprintf(fileID, '%f ', beamSource(i,1));
    fprintf(fileID, '%f ', beamSource(i,2));
    fprintf(fileID, '%f ', beamSource(i,3));  
    fprintf(fileID, '\n');
end
for i = 1:nBixels    
    fprintf(fileID, '%d ', iBeam(i)-1);  
    fprintf(fileID, '%f ', bixelCorner(i,1));
    fprintf(fileID, '%f ', bixelCorner(i,2));
    fprintf(fileID, '%f ', bixelCorner(i,3));
    fprintf(fileID, '%f ', bixelSide1(i,1));
    fprintf(fileID, '%f ', bixelSide1(i,2));
    fprintf(fileID, '%f ', bixelSide1(i,3));
    fprintf(fileID, '%f ', bixelSide2(i,1));
    fprintf(fileID, '%f ', bixelSide2(i,2));
    fprintf(fileID, '%f ', bixelSide2(i,3));
    fprintf(fileID, '\n');
end

fclose(fileID);