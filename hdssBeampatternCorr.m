function sonar = hdssBeampatternCorr(sonar,alphaCoefs,RefDepths)
%
%hdssBeampatternCorr inputs beam pattern correction coefficients 
%       alphaCoefs(4,depths,beams) at depths RefDepths(1:92)
%   and
%
%       1) If necessary, interpolates the coefficients to the depth bins
%       used in the current data set.
%
 %       and:
 %       
 %           2)  Applies the coefficients to the matched filtered cov data,
 %           rotating the phase of the covariance by a multiplicative
 %           factor that depends on the vertical gradient of log intensity.
 %
 %          this has the effect of altering the beam velocity in advance of subsequent
 %          operations.
 %
 %Step 1  Do we need to interpolate the correction coefficients?
 %
        ThisDepth=sonar.depths;
        
        %RefDepths=[1:90]'*13; % depths at which alphas were calculated
        %alphaCoefs=aSM;

% If the data being corrected have a different range-bin length, then an 
%   interpolation is called for so that the proper coefficient corrects data 
%   from the same actual range, not the same bin #.       
        
        % check whether sonar.depths == RefDepths, if not, will need to
        % interpolate the correction onto sonar.depth
        Error=sum((ThisDepth(1:10)-RefDepths(1:10)).^2);
        if (Error > 0.01); interpolate=1;
        else interpolate=0; end;
        
        RefDepths=RefDepths(2:end-1);
 %
 %
 %      Now step thru four beams and correct nrec data records
 %
        for ibeam=1:4;
            %
            %   get correction coefficients
            alpha=ones(4,length(ThisDepth)-2);
            if (interpolate==1)
                for icoef=1:4
                    alpha(icoef,:)=interp1(RefDepths(9:end),alphaCoefs(icoef,9:end,ibeam),ThisDepth(1:end-2));
                end
            else
                alpha=alphaCoefs(:,:,ibeam);
            end
            %
            %
            dz=ThisDepth(2)-ThisDepth(1);
            %
            int=sonar.int(:,:,ibeam);
            recs=size(int,2);
            
            %AFW changed from sonar.cov to sonar.covs (use the filtered one)
            cov=sonar.covs(:,:,ibeam);
            
            Correction=ones(size(int));
            VbeamCorr=ones(size(int));
            
            dLogIdz=(log10(int(3:end,:))-log10(int(1:end-2,:)))/(2*dz);
            Correction(3:end-2,:)=alpha(1,3:end)'*ones(1,recs)+(alpha(2,3:end)'*ones(1,recs)).*dLogIdz(1:end-2,:)....
                +(alpha(3,3:end)'*ones(1,recs)).*dLogIdz(2:end-1,:)+(alpha(4,3:end)'*ones(1,recs)).*dLogIdz(3:end,:);
            
            Correction(3:end-2,:)=sin(Correction(3:end-2,:))./(sin(alpha(1,1:end-2))'*ones(1,recs));
            VbeamCorr=angle(cov)./Correction;   %Corrects velocities
            
            sonar.covb(:,:,ibeam)=abs(cov).*exp(1i*VbeamCorr);
            %   on to next beam
        end;


end

