function [firstdate lastdate] = hdssGetCovFileDate(fname)
% [firstdate lastdate] = hdssGetCovFileDate(fname)

if nargin < 1
	display('Usage: [firstdate lastdate] = hdssGetCovfileDate(fname)');
	return;
end
%%
d=dir(fname);
if length(d) < 0
	display([fname ' not found.']);
	return
end	


[pathstr, name, ext, versn] = fileparts(fname);
if ~strcmp(ext, '.hdss_cov') 
	display([fname ' does not have the extension .hdss_cov.']);
	return
end


fin = fopen(fname,'r','ieee-le');
if fin<0
	error([fname ' could not be opened.']);
	return
end;
	
%%
% display('Reading file headers.');

sonar = hdssReadHeader(fname);

if ~exist('daslayout'), hdssDefineCStructs; end;


nbytes = d.bytes-sonar.header.total_header_file_size;
total_record_size = sonar.header.rheader_size + sonar.header.sonar_data_size ...
							+ sonar.header.tds_recs*sonar.header.tds_data_size;
sonar.nrecs = floor(nbytes/total_record_size);

%% Read data

% fprintf(1, 'Reading data.\n');

% Sonar data
[m,n]=size(rheaderlayout);

fseek(fin, sonar.header.total_header_file_size, 'bof');
for i=1:3
	firstdate = fread(fin,rheaderlayout{i,3},rheaderlayout{i,1});
end

fseek(fin, sonar.header.total_header_file_size + sonar.header.rheader_size ...
			+ sonar.header.sonar_data_size, 'bof');
for i=1:5
	firstyear = fread(fin, tdslayout{i,3}, tdslayout{i,1});
end;

if (firstdate & firstyear)		 % catch bad records which have invalid time stamps
	firstdate = datenum(firstdate/86400/20 + datenum([firstyear 1 1 0 0 0]));
else
	firstdate = 0;
end

fseek(fin, sonar.header.total_header_file_size + ...
				(sonar.nrecs-1)*total_record_size, 'bof');
for i=1:3
	lastdate = fread(fin,rheaderlayout{i,3},rheaderlayout{i,1});
end;

fseek(fin, sonar.header.total_header_file_size + (sonar.nrecs-1)*total_record_size ...
	+ sonar.header.rheader_size + sonar.header.sonar_data_size , 'bof');
for i=1:5
	lastyear = fread(fin, tdslayout{i,3}, tdslayout{i,1});
end;

if (lastdate & lastyear)		% catch bad records which have invalid time stamps
	lastdate = datenum(lastdate/86400/20 + datenum([lastyear 1 1 0 0 0]));
else
	lastdate = 0;
end

fclose(fin);