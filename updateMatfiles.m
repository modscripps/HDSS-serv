function sonar = updateMatfiles(sequencesToAvg, daysBackToUpdate, csound)

if nargin < 1, sequencesToAvg  = 30; end;
if nargin < 2, daysBackToUpdate = 3; end;	% Set a limit on how far back to update
if nargin < 3, csound = 1540;		 end;	% Used for VRU correction before averaging

avgTimeSecs = 2*sequencesToAvg;
avgTimeMins	= round(sequencesToAvg/30);
avgTimeDays = sequencesToAvg/2/86400;

sonarsToUpdate	= {'50', '140'}
% sonarsToUpdate	= {'50'}
% sonarsToUpdate	= {'140'}

updateTime = now;

%%	
for si = 1:length(sonarsToUpdate)
	sonarType = sonarsToUpdate{si};
%
	dataVolume		= '/Volumes/hdssServer_Ext';
	
	covDirectory	= sprintf('%s/%sk/Covariance', dataVolume, sonarType);

	matDirectory	= sprintf('%s/%sk/Matfiles', dataVolume, sonarType);

	if ~isdir(matDirectory), mkdir(matDirectory); end

%%
	today		= floor(updateTime);

	for theDatenum = today:-1:today-daysBackToUpdate

        theMatFile = sprintf('%s/%sk_%s_%ds.mat', ...
							matDirectory, sonarType, datestr(theDatenum, 29), avgTimeSecs);
% 		theMatFile = sprintf('%s/%sk_%s_%dm.mat', ...
% 							matDirectory, sonarType, datestr(theDatenum, 29), avgTimeMins);
						
		if exist(theMatFile, 'file')
			display(['Loading ' theMatFile]);
			load(theMatFile);
	
			if exist('sonar') & isstruct(sonar)
				timerange  = datestr(sonar.datenum([1 end]));
				datapoints = find(~isnan(sonar.TDS.time_mark));

				if sonar.datenum(datapoints(end)) < theDatenum+1-avgTimeDays | isnan(sonar.TDS.time_mark(end))
					display('Updating...')
					sonar = AverageCovFiles(covDirectory, sequencesToAvg, theDatenum, theDatenum+1, sonar);
                    if isstruct(sonar)
                        sonar = ProcessCov(sonar);
                        display(['Saving ' theMatFile]);
                        save(theMatFile, 'sonar');
                    else
                        display('No new data.')
                    end
                    
				else	
					display('File is up to date.');
				end
			end
			
		else	
			display(['Creating new file ' theMatFile]);
			sonar = AverageCovFiles(covDirectory, sequencesToAvg, theDatenum, theDatenum+1);
			if isstruct(sonar)
				sonar = ProcessCov(sonar)
				display(['Saving ' theMatFile]);
				save(theMatFile, 'sonar');
			else
				display(['No data to create ' theMatFile '.']);
			end
		end
		display ' ';
	end
%%	
end
