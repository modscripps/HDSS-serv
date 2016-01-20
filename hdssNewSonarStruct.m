function sonar = hdssNewSonarStruct(sonar_template, new_recs, tds_recs, range_bins, sonarlayout);
% hdssNewSonarStruct: Get a new new sonar struct populated with NaNs
%	sonar = hdssNewSonarStruct(sonar_template, new_recs, tds_recs, range_bins, sonarlayout);

if nargin < 5
	sonarlayout = hdssDefineSonarStruct;
end

try
	% Use some information sonar_template
	if nargin < 4
		range_bins	= size(sonar_template.cov,1);
	end

	if nargin < 3
		tds_recs	= size(sonar_template.TDS.time_mark,1);
	end

	sonar.filename	= {};  % sonar_template.filename;
	sonar.dasinfo	= sonar_template.dasinfo;
catch
	error('First argument must be a valid structure.')
end

for si = 7:length(sonarlayout)
	if strncmp(sonarlayout{si, 1}, 'TDS.', 4)
		eval( sprintf('sonar.%s = NaN * zeros(%d,%d);',...
 					sonarlayout{si, 1}, tds_recs, new_recs) );
% 	elseif strcmp(sonarlayout{si, 2}, 'meanw')
% 		eval( sprintf('sonar.%s = NaN * zeros(%d,%d,%d);', ...
% 					sonarlayout{si, 1}, range_bins, new_recs, 4) );
	else
		eval( sprintf('sonar.%s = NaN * zeros(1,%d);', ...
					sonarlayout{si, 1}, new_recs) );
	end
end

sonar.cov0	= NaN * (1+i) * zeros(range_bins, new_recs, 4);
sonar.int0	= NaN * zeros(range_bins, new_recs, 4);

sonar.cov	= NaN * (1+i) * zeros(range_bins, new_recs, 4);
sonar.int	= NaN * zeros(range_bins, new_recs, 4);

sonar.covs0	= NaN * (1+i) * zeros(range_bins, new_recs, 4);
sonar.covs	= NaN * (1+i) * zeros(range_bins, new_recs, 4);