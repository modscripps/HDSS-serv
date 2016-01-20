function filelist = ListCovFiles(sourceDir, minDate, maxDate)
% function filelist = ListCovFiles(sourceDir, minDate, maxDate)

if nargin < 2, minDate	= 0;	end
if nargin < 3, maxDate	= 1e6;	end

%%
% Tavg = Navg * 2/86400;


% display('Finding covariance files.');
% Get list of cov files
filelist	= dir([sourceDir '/*.hdss_cov']);

if length(filelist) == 0
	display('Found no covariance files in the source directory.');
	return
end

% Limit files to those newer than minDate
filelist = filelist([filelist.datenum] >= minDate);

if length(filelist) == 0
	display(['Found no covariance records newer than ' datestr(minDate)]);
	return
end

% Attach timestamps of first and last records to each cov file
display('Reading timemarks from covariance files.'); 
filelist = TimestampCovFiles(filelist, sourceDir);

% Further limit files by timestamps between min and max datenum
filelist = filelist([filelist.lastdate] >= minDate ...
			& [filelist.firstdate] < maxDate ...
			& [filelist.lastdate] & [filelist.firstdate]);	% require nonzero dates
		
if length(filelist) == 0
	display(['No covariance files found between ' ...
				datestr(minDate) ' and ' datestr(maxDate)]);
	return
end
		
% Sort the timestamped cov file list by first record timestamps
display('Sorting covariance files by timemark.');
filelist = SortCovList(filelist);

display(sprintf('Found %d file(s).', length(filelist)));
% filelist.name

end

function filelist = TimestampCovFiles(filelist, sourceDir)

	N = length(filelist);

	for j = 1:N
%         fullfile(sourceDir, filelist(j).name)
		[filelist(j).firstdate filelist(j).lastdate] ...
			= hdssGetCovFileDate(fullfile(sourceDir, filelist(j).name));

% 		filelist(j).firstdate = firstdate;
% 		filelist(j).lastdate  = lastdate;
	end
	
	% Remove files with bad timestamps
	filelist = filelist(find([filelist.firstdate] & [filelist.lastdate]));
end

% Sort the list of timestamped cov files by their firstdates.
% Based on hdssSortFilesListbyTime by Achintya Madduri, Oct 6th 2008.

function filelist = SortCovList(filelist)

	N = length(filelist);
	indexlist = [1:N]';

	for j = 1:N
		indexlist(j,2) = filelist(j).firstdate;
	end

	sortedlist = sortrows(indexlist, 2);

	for j = 1:N
		sortedfilelist(j) = filelist(sortedlist(j,1));
	end

end
