function matRad_beamletsFileCreatorMC(file,stf,pln)

nbeamlets = sum([stf(:).totalNumOfBixels]);
beamSource = zeros(pln.propStf.numOfBeams, 3);
beamNum  = NaN*ones(nbeamlets,1);
bixelCorner = zeros(nbeamlets,3);
bixelSide1 = zeros(nbeamlets,3);
bixelSide2 = zeros(nbeamlets,3);

counter = 0;

% The physical coordinate system (CT coordinate system) is define in cm
for i = 1:pln.propStf.numOfBeams % loop over all beams

    % define beam source in physical coordinate system in cm
    beamSource(i,:) = (stf(i).sourcePoint + stf(i).isoCenter)/10;
    
    % loop over all rays / for photons we only have one bixel per ray
    for j = 1:stf(i).numOfRays 
        
        counter = counter + 1;
        
        beamNum(counter) = i;
        
        % Corner position
        bixelCorner(counter,:) = (stf(i).ray(j).beamletCornersAtIso(1,:) +...
                                    stf(i).isoCenter)/10;                       
        % Calculate the bixel side from the corners of the bixel
        bixelSide1(counter,:) = (stf(i).ray(j).beamletCornersAtIso(2,:)) - ...
                          (stf(i).ray(j).beamletCornersAtIso(1,:));
        bixelSide2(counter,:) = (stf(i).ray(j).beamletCornersAtIso(4,:)) - ...
                          (stf(i).ray(j).beamletCornersAtIso(1,:));
    end  
end

%%%% Writing the beamlets file
outputname = strtok(file,'.mat');
ext = '.beamlet';

fileID = fopen(strcat(outputname,ext),'w');

% Source position (x, y, z):
fprintf(fileID, '%d ', nbeamlets(:));
fprintf(fileID, '\n');
for i = 1:pln.propStf.numOfBeams
    fprintf(fileID, '%f ', beamSource(i,2));
    fprintf(fileID, '%f ', beamSource(i,1));
    fprintf(fileID, '%f ', beamSource(i,3));  
    fprintf(fileID, '\n');
end
for i = 1:nbeamlets     
    fprintf(fileID, '%d ', beamNum(i));  
    fprintf(fileID, '%f ', bixelCorner(i,2));
    fprintf(fileID, '%f ', bixelCorner(i,1));
    fprintf(fileID, '%f ', bixelCorner(i,3));
    fprintf(fileID, '%f ', bixelSide1(i,2));
    fprintf(fileID, '%f ', bixelSide1(i,1));
    fprintf(fileID, '%f ', bixelSide1(i,3));
    fprintf(fileID, '%f ', bixelSide2(i,2));
    fprintf(fileID, '%f ', bixelSide2(i,1));
    fprintf(fileID, '%f ', bixelSide2(i,3));
    fprintf(fileID, '\n');
end

% fprintf(fileID, '%d ', nbeamlets(:));
% fprintf(fileID, '\n');
% fprintf(fileID, '%d ', beamNum(:));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', beamSource(:,2));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', beamSource(:,1));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', beamSource(:,3));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelCorner(:,2));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelCorner(:,1));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelCorner(:,3));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide1(:,2));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide1(:,1));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide1(:,3));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide2(:,2));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide2(:,1));
% fprintf(fileID, '\n');
% fprintf(fileID, '%f ', bixelSide2(:,3));
% fprintf(fileID, '\n');

fclose(fileID);

end