function sonar = hdssReadRaw(fname,recs,stride)
% sonar = hdssReadRaw(fname,recs,stride)
% 	recs   : number of records to read.  0 only returns basic info.
%   stride : default = 1
%%
% fname = ''
% if nargin<1
% fname=[];
% end;
% if isempty(fname)
%	[FileName,PathName,FilterIndex]  = uigetfile('*.hdss_raw');
%	fname = fullfile(PathName,FileName)
% end;
% 
if nargin<2
	recs=128;
end;

if nargin<3
	stride=1;
end

%%
d=dir(fname);
% fname
fin = fopen(fname,'r','ieee-le');
if fin<0
	error(sprintf('Could not open %s',fname));
end;

%%
sonar = [];
sonar.filename = d.name

for j = 1:9
	eval(['sonar.' fgetl(fin) ';']);
% 	eval([fgetl(fin) ';']);
end

%%
display('Reading sonar headers.');

hdssDefineCStructs;

fseek(fin, sonar.text_header_file_size, 'bof');

% Read the dasRec   
[m,n]=size(daslayout);
for i=1:m
	eval(['sonar.dasinfo.' daslayout{i,2} ' = fread(fin, ' num2str(daslayout{i,3}) ', ''' daslayout{i,1} ''');']);
% 	theline = fread(fin,daslayout{i,3},daslayout{i,1})
end

%% Dereference some useful variables
sonar.SonarType	= deblank(sonar.dasinfo.SonarCom.SonarType');
sonar.nchannels = sonar.dasinfo.SonarCom.n_data_channels;
sonar.nsamples	= sonar.dasinfo.SonarCom.samples_to_acquire;
sonar.tds_recs	= sonar.dasinfo.TDS.TDSrecs;

% Calculate total data record size
sonar.total_record_size = sonar.rheader_size + sonar.sonar_data_size + sonar.tds_recs*sonar.tds_data_size;

% Calculate file info
nbytes = d.bytes-sonar.total_header_file_size;

%% Display info and exit if recs = 0
if recs == 0
	sonar.nrecs = floor(nbytes/sonar.total_record_size)
	return;
end

%% Initialize arrays...
display('Initializing arrays.');
% sonar.nrecs = min(floor(nbytes/sonar.total_record_size), recs);
data = NaN*ones(sonar.nchannels, sonar.nsamples, sonar.nrecs);
sonar.timemark = NaN*ones(1,sonar.nrecs);


% sonar.rheader = NaN*ones(nrecs);

% TDS
[m,n]=size(tdslayout);
for i=1:m
	eval(['sonar.TDS.' tdslayout{i,2} ' = NaN * zeros(sonar.tds_recs, sonar.nrecs);']);
end;

%% Loop through data records

display('Reading data.')

num = 0;
for ij = 1:stride:sonar.nrecs;	% length(recTodo)	
	fres=fseek(fin, sonar.total_header_file_size + num*sonar.total_record_size, 'bof');
	if fres == 0
		num=num+1;
		
		% Display progress indicator
% 		if mod(num,10)==0
% 			fprintf(1,'.');
% 		end;

		% Read a data record:
		display(sprintf('Reading record %d.', num))

		% rheader
		display('rheader');
		
		[m,n]=size(rheaderlayout);
		for i=1:m
			dat = fread(fin,rheaderlayout{i,3},rheaderlayout{i,1});
			if ~isempty(dat)
				% This happens because the Mac EOF is different from everyone
				% else's.  
				%          num = num-1;
				eval(['sonar.rheader(num).' rheaderlayout{i,2} ' = dat;']);
			end;
		end;
		
		% sonar data
		display('sonar data')
		
		if ~isempty(dat)
			data(:,:,num)=fread(fin, [sonar.nchannels sonar.nsamples], 'int16');
		end;
		
		% TDS
		display('TDS')
				
		[m,n]=size(tdslayout);
		
		for tds_rec = 1:sonar.tds_recs
			for i=1:m
				eval(['sonar.TDS.' tdslayout{i,2} '(tds_rec,num) = fread(fin, ' num2str(tdslayout{i,3}) ', ''' tdslayout{i,1} ''');']);
			end;
		end

	end;
	sonar.timemark(num)= sonar.rheader(num).timemark;
end;

%%
fclose(fin);

% % Leave the following out for now
% % Combine real and imaginary data channels into n/2 complex channels
% newchannels = sonar.nchannels/2;
% for theStream = 1:newchannels
% 	data(theStream,:,:) = data(2*(theStream-1)+1,:,:) + i*data(2*theStream,:,:);
% end
% sonar.data = data(1:newchannels,:,:);

sonar.data = shiftdim(data,1);
fprintf(1, 'Done. %d records read.\n', num);

return