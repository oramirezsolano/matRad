function writeBeamletfileMCRes(file,nBeams,nBixels,beamSource,iBeam,bixelCorner,bixelSide1,bixelSide2)

outputname = strtok(file,'.mat');
ext = '.beamlet';

fileID = fopen(strcat(outputname,ext),'w');

% Source position (x, y, z):
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