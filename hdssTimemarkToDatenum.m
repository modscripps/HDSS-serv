function theDatenum = hdssTimemarkToDatenum(sonarTimemark, dataYear)
	
if nargin<2
	dataYear=2009
end

theDatenum = datenum([ dataYear 1 1 0 0 0 ]) + sonarTimemark/20/86400;
				
	
return