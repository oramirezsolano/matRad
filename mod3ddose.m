clc; clear;
tic

% Open EGS phantom file and create output file
% file = 'HEAD_AND_NECK';
file = 'TG119';
% file = 'PROSTATE';
% file = 'LIVER';
% file = 'BOXPHANTOM';

load(strcat(file,'.mat'));

ext = '_5x5.3ddose';
inputname = strcat(file,ext);
outputname = strcat(file,'_mod');
outputname = strcat(outputname,ext);

fpin = fopen(inputname,'r');
fpout = fopen(outputname,'w');

%% Define desired transformations

% Displace x, y and z boundaries in order to have desired point in the
% origin (i.e (0.0, 0.0, 0.0)). Units in cm
xpoint = min(ct.x)/10;
ypoint = min(ct.y)/10;
zpoint = 0.0;

% Read dimensions of the phantom
fline = fgetl(fpin);
phantsizes = sscanf(fline,'%d');
nx = phantsizes(1);
ny = phantsizes(2);
nz = phantsizes(3);

% Write dimensions of the phantom
fprintf(fpout, fline);
fprintf(fpout,'\n');

% Now read boundaries in each direction
fline = fgetl(fpin);
xbounds = sscanf(fline,'%f');
fline = fgetl(fpin);
ybounds = sscanf(fline,'%f');
fline = fgetl(fpin);
zbounds = sscanf(fline,'%f');

%% Transform boundaries
xbounds = xbounds - xpoint;
ybounds = ybounds - ypoint;
zbounds = zbounds - zpoint;

% Now write boundaries in each direction
fprintf(fpout, '  %.11f\t', xbounds);
fprintf(fpout,'\n');
fprintf(fpout, '  %.11f\t', ybounds);
fprintf(fpout,'\n');
fprintf(fpout, '  %.11f\t', zbounds);
fprintf(fpout,'\n');

while ~feof(fpin)
    fline = fgetl(fpin);
    fprintf(fpout, fline);
    fprintf(fpout,'\n');
end

% for k=1:nz
%     waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
%     for j=1:ny
%         fprintf(fpout,'%c', num2str(matCube(:,j,k)));
%         fprintf(fpout,'\n');
%     end
%     fprintf(fpout,'\n');
% end

% Fill cube with doses
% wbar = waitbar(0,'1','Name','Reading doses');
% matCube = NaN*ones(nx+1,ny+1,nz+1,'uint16'); % NaN is to catch possible errors
% for k=1:nz+1
%     waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
%     for j=1:ny+1
%         fline = fgetl(fpin);
%         carray = sscanf(fline,'%c');
%         for i=1:nx+1
%             matCube(i,j,k) = str2num(carray(i));
%         end
%     end
%     fline = fgetl(fpin);
% end

% Fill cube with uncertainties
% wbar.Name = 'Reading uncertainties';
% matRho = zeros(nx,ny,nz);
% for k=1:nz
%     waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
%     for j=1:ny
%         fline = fgetl(fpin);
%         rarray = sscanf(fline,'%f');
%         for i=1:nx
%             matRho(i,j,k) = rarray(i);
%         end
%     end
%     fline = fgetl(fpin);
% end
% 
% %% Write modified dose distribution to file
% 
% % % Write first line, it corresponds to the number of materials in the 
% % % phantom file
% % fprintf(fpout,' %d\n',nmed);
% % 
% % % Now write material names of the phantom
% % for i=1:nmed
% %     fprintf(fpout, '%s\n', matnames{i,1});
% % end
% % 
% % % Write dummy line with zeros
% % fprintf(fpout, '%s\n', dummyzeros);
% 
% % % Write dimensions of the phantom
% % fprintf(fpout,'%5d', phantsizes(:));
% % fprintf(fpout,'\n');
% % 
% % % Now write boundaries in each direction
% % fprintf(fpout, '  %.2f\t', xbounds);
% % fprintf(fpout,'\n');
% % fprintf(fpout, '  %.2f\t', ybounds);
% % fprintf(fpout,'\n');
% % fprintf(fpout, '  %.2f\t', zbounds);
% % fprintf(fpout,'\n');
% 
% % Write cube with materials
% wbar.Name = 'Writing doses';
% for k=1:nz
%     waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
%     for j=1:ny
%         fprintf(fpout,'%c', num2str(matCube(:,j,k)));
%         fprintf(fpout,'\n');
%     end
%     fprintf(fpout,'\n');
% end
% 
% % Write cube with densities
% wbar.Name = 'Writing uncertainties';
% for k=1:nz
%     waitbar(k/nz,wbar,sprintf('Slice: %d/%d',k,nz))
%     for j=1:ny
%         fprintf(fpout,'%f\t', matRho(:,j,k));
%         fprintf(fpout,'\n');
%     end
%     fprintf(fpout,'\n');
% end

% Close all files and cleaning
fclose('all');
% delete(wbar);
toc