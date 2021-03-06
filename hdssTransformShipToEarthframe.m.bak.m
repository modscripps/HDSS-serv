function sonar = TransformShipToEarthframe(sonar, tds_t);

tss_offset = 0.0.*pi/180
navfiltlength = 1;

if nargin < 2 || size(sonar.TDS.time_mark,1) == 1
	tds_t = 1;
end

%%
% Get array dimensions
[nbins nrecs nbeams] = size(sonar.cov);

%%
filt = gausswin(navfiltlength)';  filt = filt/sum(filt);

sog = sonar.TDS.pcode.sog(tds_t,:);
sog = conv2(sog,filt,'same')/3.6;

cog = sonar.TDS.pcode.cogT_cos(tds_t,:)+i*sonar.TDS.pcode.cogT_sin(tds_t,:);
cog = conv2(cog(1:end),filt,'same');

tss = sonar.TDS.TSS.heading_cos(tds_t,:) + i*sonar.TDS.TSS.heading_sin(tds_t,:);
tss = conv2(tss(1:end),filt,'same');

adu2 = sonar.TDS.ADU2.heading_cos(tds_t,:) + i*sonar.TDS.ADU2.heading_sin(tds_t,:);
adu2 = conv2(adu2,filt,'same');

Psi = angle(tss) - tss_offset;
Phi = angle(cog) - Psi;
Padu2 = angle(cog) - angle(adu2);

sonar.nav = exp(-i*Phi).*sog;

%% Special case for DP mode (< 0.20 m/s) handled by absolute position,
%% should only be applied to single-ping data at this point

dt  = conv2(sonar.datenum,[1 0 -1],'same')*86400; dt([1 end])=NaN;

if max(dt) < 4  % detect single-ping data
	DPthreshold = 0.25;
	DP = find(sog < DPthreshold);

	dlat = conv2(sonar.TDS.pcode.lat(tds_t,:),[1 0 -1],'same');
	dlon = conv2(sonar.TDS.pcode.lon(tds_t,:),[1 0 -1],'same');

	dp = dlon.*cosd(sonar.TDS.pcode.lat(tds_t,:)) + i*dlat;
	dt  = conv2(sonar.datenum,[1 0 -1],'same')*86400; dt([1 end])=NaN;

	DPnav = dp./dt * 1852*60;

	sonar.nav(DP) = DPnav(DP);
end
%% 
U = sonar.u + ones(sonar.nbins,1)*sonar.nav;

sonar.U = ones(sonar.nbins,1)*exp(i*(pi/2-Psi)) .* U;

sonar.U_z = conv2(sonar.U,[1 0 -1]','same')./repmat(conv2(sonar.depths,[1 0 -1]','same'),[1 nrecs]);