clc; clear;
tic

% Open EGS phantom file and create output file
% file = 'HEAD_AND_NECK';
% file = 'TG119';
% file = 'PROSTATE';
% file = 'LIVER';
file = 'BOXPHANTOM';

load(strcat(file,'.mat'));

ext = '.egsphant';
inputname = strcat(file,ext);
outputname = strcat(file,'_mod');
outputname = strcat(outputname,ext);

fpin = fopen(inputname,'r');
fpout = fopen(outputname,'w');

%% Define desired transformations

% Displace x, y and z boundaries in order to have desired point in the
% origin (i.e (0.0, 0.0, 0.0)). Units in cm
xpoint = abs(min(ct.x))/10;
ypoint = abs(min(ct.y))/10;
zpoint = abs(min(ct.z))/10;

%% Read first line, it corresponds to the number of materials in the phantom
% file
fline = fgetl(fpin);
nmed = sscanf(fline,'%d');

% Now read material names in the phantom
matnames = cell(nmed,1);
for i=1:nmed
    fline = fgetl(fpin);
    matnames{i,1} = sscanf(fline,'%s');
end

% Read dummy line with zeros
dummyzeros = fgetl(fpin);

% Read dimensions of the phantom
fline = fgetl(fpin);
phantsizes = sscanf(fline,'%d');
nx = phantsizes(1);
ny = phantsizes(2);
nz = phantsizes(3);

% Now read boundaries in each direction
fline = fgetl(fpin);
xbounds = sscanf(fline,'%f');
fline = fgetl(fpin);
ybounds = sscanf(fline,'%f');
fline = fgetl(fpin);
zbounds = sscanf(fline,'%f');

% Fill cube with materials
wbar = waitbar(0,'1','Name','Reading materials');
matCube = NaN*ones(nx,ny,nz,'uint16'); % NaN is to catch possible errors
for k=1:nz
    waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
    for j=1:ny
        fline = fgetl(fpin);
        carray = sscanf(fline,'%c');
        for i=1:nx
            matCube(i,j,k) = str2num(carray(i));
        end
    end
    fline = fgetl(fpin);
end

% Fill cube with densities
wbar.Name = 'Reading densities';
matRho = zeros(nx,ny,nz);
for k=1:nz
    waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
    for j=1:ny
        fline = fgetl(fpin);
        rarray = sscanf(fline,'%f');
        for i=1:nx
            matRho(i,j,k) = rarray(i);
        end
    end
    fline = fgetl(fpin);
end

%% Transform boundaries
xbounds = xbounds - xpoint;
ybounds = ybounds - ypoint;
zbounds = zbounds - zpoint;

%% Write modified phantom to file

% Write first line, it corresponds to the number of materials in the 
% phantom file
fprintf(fpout,' %d\n',nmed);

% Now write material names of the phantom
for i=1:nmed
    fprintf(fpout, '%s\n', matnames{i,1});
end

% Write dummy line with zeros
fprintf(fpout, '%s\n', dummyzeros);

% Write dimensions of the phantom
fprintf(fpout,'%5d', phantsizes(:));
fprintf(fpout,'\n');

% Now write boundaries in each direction
fprintf(fpout, '  %.2f\t', xbounds);
fprintf(fpout,'\n');
fprintf(fpout, '  %.2f\t', ybounds);
fprintf(fpout,'\n');
fprintf(fpout, '  %.2f\t', zbounds);
fprintf(fpout,'\n');

% Write cube with materials
wbar.Name = 'Writing materials';
for k=1:nz
    waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
    for j=1:ny
        fprintf(fpout,'%c', num2str(matCube(:,j,k)));
        fprintf(fpout,'\n');
    end
    fprintf(fpout,'\n');
end

% Write cube with densities
wbar.Name = 'Writing densities';
for k=1:nz
    waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
    for j=1:ny
        fprintf(fpout,'%f\t', matRho(:,j,k));
        fprintf(fpout,'\n');
    end
    fprintf(fpout,'\n');
end

% Close all files and cleaning
fclose('all');
delete(wbar);
toc