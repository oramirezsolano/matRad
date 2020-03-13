function writePhantomMCRes(dij,material,xBounds,yBounds,zBounds,ctcubeRho,cubeMatIx,file)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad ompMC monte carlo phantom file creator
% 
% call
%   writePhantomMCRes(dij,material,ompMCgeo.xBounds,ompMCgeo.yBounds,ompMCgeo.zBounds,cubeRho,cubeMatIx,file);
% 
% input
%   dij:            matRad dij struct
%   material:       number and names of material
%   x,y,zBounds:    x,y,z coordinates of ct's voxel boundaries
%   ctcubeRho:      values of ct material densities
%   cubeMatIx:      material index
%   file:           variable with the .mat file's name
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Writing the egsphant
outputname = strtok(file,'.mat');
ext = '.egsphant';
fileID = fopen(strcat(outputname,ext),'w');

nmaterial = 4;

fprintf(fileID, ' %d\n', nmaterial);
fprintf(fileID, '%s\n', material{:,1});
fprintf(fileID, '   0.0000000       0.0000000       0.0000000       0.0000000\n'); 
fprintf(fileID, '  %d', dij.doseGrid.dimensions(:));
fprintf(fileID, '\n');
fprintf(fileID, '  %.2f\t', xBounds);
fprintf(fileID, '\n');
fprintf(fileID, '  %.2f\t', yBounds);
fprintf(fileID, '\n');
fprintf(fileID, '  %.2f\t', zBounds);
fprintf(fileID, '\n');

h2 = waitbar(0,'1','Name','Writing number of material');

for z = 1:dij.doseGrid.dimensions(3)
    waitbar(z/dij.doseGrid.dimensions(3),h2,sprintf('Slice: %d/%d',z,dij.doseGrid.dimensions(3)))
    for x = 1:dij.doseGrid.dimensions(1)
        for y = 1:dij.doseGrid.dimensions(2)
                fprintf(fileID, '%d', cubeMatIx{1}(x,y,z));
        end
        fprintf(fileID, '\n');
    end
    fprintf(fileID, '\n');
end
close(h2);

h3 = waitbar(0,'1','Name','Writing density of material');

for z = 1:dij.doseGrid.dimensions(3)
    waitbar(z/dij.doseGrid.dimensions(3),h3,sprintf('Slice: %d/%d',z,dij.doseGrid.dimensions(3)))
    for x = 1:dij.doseGrid.dimensions(1)
        for y = 1:dij.doseGrid.dimensions(2)
            fprintf(fileID,'%f\t',ctcubeRho{1}(x,y,z));
        end
        fprintf(fileID, '\n');
    end
    fprintf(fileID, '\n');
end
close(h3);

h = msgbox('Phantom file successfully created!!!');

fclose(fileID);

end