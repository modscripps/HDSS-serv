function sonaravg = hdssAverageCov(sonar, ti, sonaravg, ai)

	if nargin < 4, ai = 1;		end;
	
	if nargin < 3
		sonaravg = hdssNewSonarStruct(sonar, 1, 1);
	end

	if nargin < 2
		ti = [1:size(sonar.cov,2)];
	elseif length(ti) == 2
		ti = [ti(1):ti(2)];
	end;
	
% 	for fi = 1:length(sonar.filename)
% 		if ~ismember(sonar.filename{fi}, sonaravg.filename)
% 			sonaravg.filename = [sonaravg.filename; sonar.filename{fi}];
% 		end
% 	end
% 	
% 	if isfield(sonaravg, 'dasinfo') & isempty(sonaravg.dasinfo)
% 		sonaravg.dasinfo = sonar.dasinfo;
% 	end
	
	
	sonarlayout = hdssDefineSonarStruct;
	
	for j = 1:length(sonarlayout)
		fieldname = sonarlayout{j, 1};
		avgtype	  = sonarlayout{j, 2};
		
		if strcmp(avgtype, 'mean2')
			eval(sprintf('sonaravg.%s(ai) = nanmean(reshape(sonar.%s(:,ti),1,[]));', fieldname, fieldname))
		elseif strcmp(avgtype, 'mean')
			eval(sprintf('sonaravg.%s(ai) = nanmean(sonar.%s(:,ti));', fieldname, fieldname))
		elseif strcmp(avgtype, 'first')
			eval(sprintf('sonaravg.%s(ai) = sonar.%s(1,ti(1));', fieldname, fieldname))
		
        end
%         catch
%             err = lasterror;
%             display(['Error averaging field ', sonarref]);
%             message = err.message
%         end
	end

		
	% Signal-Weighted Means (normalize cov/covs by int)
	int0	= sonar.int0(:,ti,:);
	cov0	= sonar.cov0(:,ti,:);
	covs0	= sonar.covs0(:,ti,:);
	
	sonaravg.int0(:,ai,:)	= nanmean(int0,2);
	sonaravg.cov0(:,ai,:)	= nanmean(cov0./int0,2);
	sonaravg.cov0(:,ai,:)	= sonaravg.cov0(:,ai,:) ...
								./abs(sonaravg.cov0(:,ai,:)) ...
								.*abs(nanmean(cov0,2));
	sonaravg.covs0(:,ai,:)	= nanmean(covs0./int0,2);
	sonaravg.covs0(:,ai,:)	= sonaravg.covs0(:,ai,:) ...
								./abs(sonaravg.covs0(:,ai,:)) ...
								.*abs(nanmean(covs0,2));
		
	int		= sonar.int(:,ti,:);
	cov 	= sonar.cov(:,ti,:);
	covs	= sonar.covs(:,ti,:);
	
	sonaravg.int(:,ai,:)	= nanmean(int,2);
	acov	= nanmean(cov./int,2);  acov = acov./abs(acov);
	sonaravg.cov(:,ai,:)	= acov.*abs(nanmean(cov,2));
	sonaravg.covs(:,ai,:)	= nanmean(covs./int,2);
	sonaravg.covs(:,ai,:)	= sonaravg.covs(:,ai,:) ...
								./abs(sonaravg.covs(:,ai,:)) ...
								.*abs(nanmean(covs,2));
								
	% Vector averages of navigation data
	pcode.vog = sonar.TDS.pcode.sog(:,ti) ...
				.* ( sonar.TDS.pcode.cogT_cos(:,ti) ...
					+ i*sonar.TDS.pcode.cogT_sin(:,ti) );
	pcode.vog = nanmean(pcode.vog(:));
	
	sonaravg.TDS.pcode.sog(ai)		= abs(pcode.vog);
	sonaravg.TDS.pcode.cogT_cos(ai)	= real(pcode.vog) / abs(pcode.vog);
	sonaravg.TDS.pcode.cogT_sin(ai)	= imag(pcode.vog) / abs(pcode.vog);

	pcode.latlon = sonar.TDS.pcode.lon(:,ti) + i*sonar.TDS.pcode.lat(:,ti);
	pcode.latlon = nanmean(pcode.latlon(:));
	sonaravg.TDS.pcode.lon(ai) = real(pcode.latlon);
	sonaravg.TDS.pcode.lat(ai) = imag(pcode.latlon);
	
	TSS.heading = sonar.TDS.TSS.heading_cos(:,ti) ...
					+ i*sonar.TDS.TSS.heading_sin(:,ti);
	TSS.heading = nanmean(TSS.heading(:));
	TSS.heading = TSS.heading / abs(TSS.heading);		% Make a unit vector
	
	sonaravg.TDS.TSS.heading_cos(ai) = real(TSS.heading);
	sonaravg.TDS.TSS.heading_sin(ai) = imag(TSS.heading);
	
	ADU2.heading = sonar.TDS.ADU2.heading_cos(:,ti) ...
					+ i*sonar.TDS.ADU2.heading_sin(:,ti);
	ADU2.heading = nanmean(ADU2.heading(:));
	ADU2.heading = ADU2.heading / abs(ADU2.heading);	% Make a unit vector

	sonaravg.TDS.ADU2.heading_cos(ai) = real(ADU2.heading);
	sonaravg.TDS.ADU2.heading_sin(ai) = imag(ADU2.heading);
