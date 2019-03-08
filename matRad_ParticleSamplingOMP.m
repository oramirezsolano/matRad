function samplesPos = matRad_ParticleSamplingOMP(ct,stf,pln)

samples = 10; % Number of particles to be sampled

bixelSide1 = zeros(1,3);
bixelSide2 = zeros(1,3);

% CT boundaries
xBounds = [.5,(ct.cubeDim(1)+.5)]*ct.resolution.x/10;
yBounds = [.5,(ct.cubeDim(2)+.5)]*ct.resolution.y/10;
zBounds = [.5,(ct.cubeDim(3)+.5)]*ct.resolution.z/10;

% The physical coordinate system (CT coordinate system) is define in cm
for i = 1:pln.propStf.numOfBeams % loop over all beams

    % define beam source in physical coordinate system in cm
    beamSource = (stf(i).sourcePoint + stf(i).isoCenter)/10;
    
    for j = 1:stf(i).numOfRays % loop over all rays / for photons we only have one bixel per ray

        for m = 1:samples % Loop over all the particles to be sampled
                       
            % Calculate the bixel side from the corners of the bixel
            bixelSide1(1,:) = (stf(i).ray(j).beamletCornersAtIso(2,:)) - ...
                              (stf(i).ray(j).beamletCornersAtIso(1,:));
            bixelSide2(1,:) = (stf(i).ray(j).beamletCornersAtIso(4,:)) - ...
                              (stf(i).ray(j).beamletCornersAtIso(1,:));
            % Particle position sampling
            beam(i).beamLet(j).partAtIso(m,:) = ((rand*bixelSide1) + (rand*bixelSide2) + ...
                                                 stf(i).ray(j).beamletCornersAtIso(1,:) + ...
                                                 stf(i).isoCenter)/10;
            % Vector norm
            size = sqrt((beam(i).beamLet(j).partAtIso(m,1) - beamSource(1))^2 + ...
                        (beam(i).beamLet(j).partAtIso(m,2) - beamSource(2))^2 + ...
                        (beam(i).beamLet(j).partAtIso(m,3) - beamSource(3))^2);
            % Unit vectors (they follow the particle direction)
            u = ((beam(i).beamLet(j).partAtIso(m,1) - beamSource(1))/size);
            v = ((beam(i).beamLet(j).partAtIso(m,2) - beamSource(2))/size);
            w = ((beam(i).beamLet(j).partAtIso(m,3) - beamSource(3))/size);
            % Inversing the unit vectors direction to carry the particles 
            % to the CT surface
            u = -u;
            v = -v;
            w = -w;
            
            ustep = 100000;
            % Calculate the minimum distance from the particle position to
            % the CT boundaries
            if (u > 0.0)
                dist = (xBounds(2) - beam(i).beamLet(j).partAtIso(m,1))./u;
                if (dist < ustep) 
                    ustep = dist;
                end
            elseif (u < 0.0)
                dist = -(beam(i).beamLet(j).partAtIso(m,1) - xBounds(1))./u;
                if (dist < ustep) 
                    ustep = dist;
                end         
            end
            
            if (v > 0.0)
                dist = (yBounds(2) - beam(i).beamLet(j).partAtIso(m,2))./v;
                if (dist < ustep) 
                    ustep = dist;
                end
            elseif (v < 0.0)
                dist = -(beam(i).beamLet(j).partAtIso(m,2) - yBounds(1))./v;
                if (dist < ustep) 
                    ustep = dist;
                end
            end
            
            if (w > 0.0)
                dist = (zBounds(2) - beam(i).beamLet(j).partAtIso(m,3))./w;
                if (dist < ustep) 
                    ustep = dist;
                end
            elseif (w < 0.0)
                dist = -(beam(i).beamLet(j).partAtIso(m,3) - zBounds(1))./w;
                if (dist < ustep) 
                    ustep = dist;
                end              
            end
            % Taking the particle position from the isocenter to the CT 
            % surface
            beam(i).beamLet(j).partAtSurf(m,1) = beam(i).beamLet(j).partAtIso(m,1) + (ustep*u);
            beam(i).beamLet(j).partAtSurf(m,2) = beam(i).beamLet(j).partAtIso(m,2) + (ustep*v);
            beam(i).beamLet(j).partAtSurf(m,3) = beam(i).beamLet(j).partAtIso(m,3) + (ustep*w);
            % Getting the Region Index in the surface (where the particle
            % hits)
            beam(i).beamLet(j).indReg(m,1) = 1 + (floor(beam(i).beamLet(j).partAtSurf(m,1)/(ct.resolution.x/10))) + ...
                                                (floor(beam(i).beamLet(j).partAtSurf(m,2)/(ct.resolution.y/10)))*ct.cubeDim(1) + ...
                                                (floor(beam(i).beamLet(j).partAtSurf(m,3)/(ct.resolution.z/10)))*ct.cubeDim(1)*ct.cubeDim(2);
        end
    end  
end
% Allocate the result in the array
samplesPos = beam;

end