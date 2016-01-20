function sonar = ReadCov(fname)

d = dir(fname);
sonar.filename = {d.name};

p = mfilename('fullpath');
[pathstr, name, ext, versn] = fileparts(p);
[pathstr '/CovToArray ' fname];

[status, result] = unix([pathstr '/CovToArray ' fname]);
CovArrayFile = [fname 'array'];
if exist(CovArrayFile, 'file')
	fpIn = fopen(CovArrayFile, 'r','ieee-le');
else
	error('Array conversion file not found. Exiting.');
end

hdssDefineCStructs;

%% dasRec
% dasrec_size = fread(fpIn, 1, 'uint32');
%%
[m,n]=size(daslayout);
for j=1:m
	eval(sprintf('sonar.dasinfo.%s = fread(fpIn, %d, ''%s'');', daslayout{j,2}, daslayout{j,3}, daslayout{j,1}));
end;

%% rheader
nrecs = fread(fpIn, 1, 'uint32');

[m,n]=size(rheaderlayout);
for j=1:m
	eval(sprintf('sonar.rheader.%s = fread(fpIn, [%d, nrecs], ''%s'');', rheaderlayout{j,2}, rheaderlayout{j,3}, rheaderlayout{j,1}));
end;


%% Cov
nrecs		= fread(fpIn, 1, 'uint32');
nbins		= fread(fpIn, 1, 'uint32');
cov_size	= nrecs * nbins;

for beam = 1:4
	sonar.cov0(:,:,beam) = fread(fpIn, [nbins, nrecs], 'float') + i*fread(fpIn, [nbins, nrecs], 'float');
end
for beam = 1:4
	sonar.int0(:,:,beam) = fread(fpIn, [nbins, nrecs], 'float');
end
for beam = 1:4
	sonar.cov(:,:,beam) = fread(fpIn, [nbins, nrecs], 'float') + i*fread(fpIn, [nbins, nrecs], 'float');
end
for beam = 1:4
	sonar.int(:,:,beam) = fread(fpIn, [nbins, nrecs], 'float');
end
	
%% TDS
nrecs		= fread(fpIn, 1, 'uint32');
tds_recs	= fread(fpIn, 1, 'uint32');
tds_size	= nrecs * tds_recs;


%%
[m,n]=size(tdslayout);
for j = 1:m
	eval(sprintf('sonar.TDS.%s = fread(fpIn, [tds_recs, nrecs], ''%s'');', tdslayout{j,2}, tdslayout{j,1}));
end
%%
fclose(fpIn);
delete(CovArrayFile);