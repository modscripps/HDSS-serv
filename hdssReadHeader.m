function sonar = hdssReadHeader(fname)
%%
fin = fopen(fname,'r','ieee-le');
if fin<0
	error([fname ' could not be opened.']);
	return
end;

d = dir(fname);
sonar.filename{1} = d.name; 
%% Reading file headers

for j = 1:9
		theline = strtrim(fgetl(fin));
		if theline(1) ~= '%'
% 			display(theline)
			eval(['sonar.header.'  theline ';'])
		end
end

%% Get the C struct layouts

if ~exist('daslayout'), hdssDefineCStructs; end;


%% Read the dasRec

fseek(fin, sonar.header.total_header_file_size-sonar.header.das_rec_size, 'bof');
[m,n]=size(daslayout);
for j=1:m
	eval(['sonar.dasinfo.' daslayout{j,2} ' = fread(fin, ' num2str(daslayout{j,3}) ', ''' daslayout{j,1} ''');']);
end;
%%

if ~isfield(sonar.header,'tds_recs'), sonar.header.tds_recs = sonar.dasinfo.TDS.TDSrecs; end;

fclose(fin);