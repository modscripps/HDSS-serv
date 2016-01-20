function sonar = ReadSonar(matDir, minDatenum, maxDatenum)
% sonar = ReadSonar(matDir, minDatenum, maxDatenum)
%   Read HDSS Mat-files from directory matDir and return a Sonar structure

today = fix(now);

if nargin < 3, maxDatenum = today; end;
	
if nargin < 2
	minDatenum = today-7;
end

d = dir(fullfile(matDir, '*.mat'));
d.name;

%% Load and concatenate the Matfiles
clear sonarcat;

for theDatenum = fix(maxDatenum):-1:minDatenum
	
	dfile = dir(sprintf('%s/*k_%s_*m.mat',matDir,datestr(theDatenum,29)));
	if length(dfile)
		theMatFile = fullfile(matDir, dfile.name);
		display(['Loading ' theMatFile]);
 		load(theMatFile);
		if exist('sonar')
			if exist('sonarcat')
				sonarcat = CatSonar(sonar, sonarcat);
			else
				sonarcat = sonar;
			end
		end
	end
end

if exist('sonarcat')
	sonar = sonarcat;
else
	error('No Matfiles found in the time range.')
end