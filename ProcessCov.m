function sonar = ProcessCov(sonar, csound)
% sonar = ProcessCov(sonar)
%	
% Revised  processing routine goes from VRU corrected covariances to Shipframe 
%	velocities.  Note that ship frame has been revised to the PHINS standard:
%	(u, v, w) = (bow, port, up).
% csound is an override that is available to hdssTransfCovToShipframe.
if nargin < 2
	csound = 1540
end

% Signal/Noise ratio
sn = abs(sonar.cov)./(sonar.int-abs(sonar.cov));
sonar.sn = nanmean(sn, 3);

% VRU correction is not needed for averaged Covs. The data were already
%	corrected for heave-pitch-roll on the single pings prior to averaging.
if ~isfield(sonar,'covs')
	sonar = hdssFilterVRUphase(sonar);
end

sonar = hdssTransformCovToShipframe(sonar, csound);

sonar = hdssTransformShipToEarthframe(sonar);

% Historical Zero Mean Layer reference might be restored some time in the future
% sonar	= hdssFilterZML(sonar, 0.89, 0.99);

if ~isfield(sonar,'datenum')	 % Don't overwrite an existing timegrid
	sonar.datenum = datenum(sonar.TDS.time_mark_year(1,:),1,1) + sonar.TDS.time_mark(1,:)/20/86400;
end

dv			= datevec(sonar.datenum);
sonar.yday	= sonar.datenum - datenum([dv(:,1) ones(length(dv),1) zeros(length(dv),1)])';

sonar.lat	= sonar.TDS.pcode.lat(1,:);
sonar.lon	= sonar.TDS.pcode.lon(1,:);

