function sonar = ReadCovMultiple(sourceDir, filecount)

if nargin<2, filecount = 1e5; end;
	
% Get file list and count
sourceList = ListCovFiles(sourceDir);
% existingFiles=dir([destDir '/*.mat']);


	
filecount = min(length(sourceList), filecount)

if filecount > 0
% Loop through all source filecount
	for fi = 1:filecount
		fprintf('%02d: %s\n', fi, sourceList(fi).name);
		
	%	Read the next sonar struct from file
		nextsonar = ReadCov(fullfile(sourceDir, sourceList(fi).name));

	%	Create or append sonar struct
		if (fi == 1)
			sonar = nextsonar;
		else
			sonar = CatSonar(sonar, nextsonar);
		end
	end
else
	display('No source filecount found.');
	sonar = [];
end

return