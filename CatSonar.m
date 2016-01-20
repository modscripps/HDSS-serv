function sonar = CatSonar(sonar1, sonar2, begin1, end1, begin2, end2)

if nargin < 3, begin1 = 1; end;

if nargin < 4, end1 = size(sonar1.cov,2); end;
	
if nargin < 5, begin2 = 1; end;

if nargin < 6, end2 = size(sonar2.cov,2); end;

if size(sonar1.cov,1) ~= size(sonar2.cov,1)
	error('Data file contains different number of bins.')
end

sonarlayout = hdssDefineSonarStruct;

try
	sonar.filename  = [sonar1.filename; sonar2.filename];
end

try
	sonar.dasinfo	= sonar1.dasinfo;
end

for j = 1:length(sonarlayout)
% 	j
	field1 = ['sonar1.', sonarlayout{j, 1}];
	field2 = ['sonar2.', sonarlayout{j, 1}];
	
	field = ['sonar.', sonarlayout{j, 1}];

	try
	% The try block allows for unprocessed/incomplete sonar structs
		if ndims(eval(field1)) == 3
% 			(sprintf('%s = cat(2, %s(:,%d:%d,:), %s(:,1:%d,:));', ...
% 							field, field1, begin1, end1, field2, end2))
			eval(sprintf('%s = cat(2, %s(:,%d:%d,:), %s(:,1:%d,:));', ...
							field, field1, begin1, end1, field2, end2))
		else 
			eval(sprintf('%s = cat(2, %s(:,%d:%d), %s(:,1:%d));', ...
							field, field1, begin1, end1, field2, end2))
		end
	end
end
