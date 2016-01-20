function sonaravg = AverageCovFiles(sourceDir, Navg, minDate, maxDate, previousSonarAvg, csound)
tic;

if nargin < 2, Navg = 60;		end
if nargin < 3, minDate = 0;		end
if nargin < 4, maxDate = 1e6;	end

minFillPerAverage	= 1.0;
pingInterval		= 2/86400;	% In days
Tavg				= Navg * pingInterval;
logSNthreshold      = 0.0;

if nargin == 5
	lastAvg = find(~isnan(previousSonarAvg.TDS.time_mark),1,'last');
	if (lastAvg)
		minDate = previousSonarAvg.datenum(lastAvg)+Tavg;
	end
end;

if nargin < 6, csound = 1540;	end


%%  Get the sorted list of cov files
filelist = ListCovFiles(sourceDir, minDate, maxDate);
filelist.name

if length(filelist) == 0 ...
		| (length(filelist) == 1 & filelist(1).lastdate < minDate + Tavg)
	sonaravg = [];
	display('Not enough data to form new averages.');
	return;
end;

if minDate == 0
	minDate = filelist(1).firstdate;
end
if maxDate == 1e6
	maxDate = filelist(end).lastdate;
end
%%  Read the first covariance file to get some info
display(['Reading file ' filelist(1).name]);
sonar = ReadCov(fullfile(sourceDir, filelist(1).name));

% Add a datenum array if not already present
if ~isfield(sonar, 'datenum')
	sonar.datenum = datenum(sonar.TDS.time_mark_year(1,:),1,1)...
			+ sonar.TDS.time_mark(1,:)/20/86400;
end
	
% Do some error checking here
if (sonar.datenum(end) >= minDate - Tavg)
	if (sonar.datenum(1) < minDate)
		ti = 1;
	else
		ti = find([sonar.datenum] >= minDate, 1, 'first');
	end
else
	error('The first file was outside the time range.');
end
		
%% Create or continue the previous time grid
if exist('previousSonarAvg')
	% Continue the same grid as previousSonarAvg
	timeGrid = [previousSonarAvg.datenum(lastAvg)+Tavg:Tavg:maxDate-Tavg];
else
	% Create a regular time grid aligned on midnight preceding first record
	timeGrid = [datenum(datestr(minDate,1)):Tavg:maxDate-Tavg];
	timeGrid = timeGrid(timeGrid>=minDate);
end

if length(timeGrid) == 0
	sonaravg = [];
	return;
end

sonaravg   = hdssNewSonarStruct(sonar,length(timeGrid),1);
avgIndex = 1;

gridLimits = datestr([timeGrid(1) timeGrid(end)])
%% Loop through Covariance file list
for fileIndex = 1:length(filelist)
	if fileIndex == 1

	else	% Read subsequent cov files
		display(['Reading file ' filelist(fileIndex).name]);
		nextsonar = ReadCov(fullfile(sourceDir, filelist(fileIndex).name));
		
		% Add a datenum array if not already present
		if ~isfield(nextsonar, 'datenum')
			nextsonar.datenum = datenum(nextsonar.TDS.time_mark_year(1,:),1,1) ...
				+ nextsonar.TDS.time_mark(1,:)/20/86400;
		end
		
		sonar = CatSonar(sonar, nextsonar, seqStart);

	end
	seqStart = 1;

	% Find timeGrid intervals which are contained in this file
	timeIndex = find(timeGrid > sonar.datenum(1) - pingInterval ...
						& timeGrid < sonar.datenum(end) - Tavg + pingInterval);
	newAvgs = length(timeIndex)
	
	if (newAvgs)
			% S/N thresholding
			sonar = hdssFilterSN(sonar, logSNthreshold);

			% VRU correction (heave/pitch/roll)
			sonar = hdssFilterVRUphase(sonar, csound);
	
		for ti = 1:newAvgs
%			ti
			lower = timeGrid(timeIndex(ti));
			seqIndex = find(sonar.datenum >= lower & sonar.datenum < lower+Tavg);
			
			if length(seqIndex) >= Navg * minFillPerAverage

% 				[num2str(timeIndex(ti)) ': ' datestr(sonar.datenum(seqIndex(1)))]

				sonaravg = hdssAverageCov(sonar, seqIndex, sonaravg, timeIndex(ti));
			end
		end
		
		if ~isempty(seqIndex)
			seqStart = seqIndex(end) + 1;
		end
	end	

end

sonaravg.filename = sonar.filename;
sonaravg.datenum  = timeGrid;
sonaravg.Navg     = Navg;

%%
if (find(~isnan(sonaravg.TDS.time_mark)))
	if exist('previousSonarAvg') & (lastAvg)
		sonaravg = CatSonar(previousSonarAvg,sonaravg,1,lastAvg);
	end
else
	sonaravg = [];
end

%%
toc