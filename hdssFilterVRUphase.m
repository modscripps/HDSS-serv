function sonar = hdssFilterVRUphase(sonar, csound, tds_index)
% VRU (Phins) phase correction for single-ping covariances

timemark	= sonar.TDS.time_mark;
tds_recs	= size(timemark,1);
%%
% Define a center for the ping
if nargin < 3
	tds_index = floor(tds_recs/3)+1;
end
%%
% Need a nominal csound

if nargin < 2
	if isfield(sonar,'csound')
		csound = sonar.csound;
	else
		csound = 1540;
	end
end

% Get array dimensions
[nbins nrecs nbeams] = size(sonar.cov);

% Correct both unfiltered (cov0) and filtered (cov)
covs0		= sonar.cov0 * NaN;
covs		= sonar.cov * NaN;

pitch		= sonar.TDS.TSS.pitch;
roll		= sonar.TDS.TSS.roll;
heave		= sonar.TDS.TSS.heave;

d_tds = diff(timemark(1:2))/20;

filt = gausswin(fix(tds_recs*2.5/2))'; filt=filt/sum(filt);

% Compute heave velocity and smooth with filt
d_heave	= conv2(heave(1:end), [1 0 -1], 'same')/(2*d_tds);
d_heave = conv2(d_heave, filt, 'same');
d_heave	= reshape(d_heave, tds_recs, []);


% Set up beam unit vectors
Az = pi/4 - pi/180;		% -42.7045 * pi/180; 
De = -pi/3 + pi/360;	% 58.6561 * pi/180; 
[x1 y1 z1] = sph2cart(Az, De, 1);

b1 = [x1 y1 z1]';
b2 = [x1 -y1 z1]';
b3 = [-x1 -y1 z1]';
b4 = [-x1 y1 z1]';
B = [b1 b2 b3 b4];

% Physical velocity to cov phase conversion factors
dt = sonar.dasinfo.SonarCom.sample_period/1e6;
tau = dt*sonar.dasinfo.time_lag;
fxmit = sonar.dasinfo.SonarCom.xmitfreq;


%% Heave velocity phase correction
display('Heave translation.');

dphase = (d_heave * z1) .* (4*pi*fxmit*tau./csound);

for t = 1:nrecs
	covs0(:,t,:)	= sonar.cov0(:,t,:) * exp(-i*dphase(tds_index,t));
	covs(:,t,:)		= sonar.cov(:,t,:) * exp(-i*dphase(tds_index,t));
end


%% Rotation transform phase correction
% Define a transform matrix T such that Tv = u, where u is the
% "stationary" ship frame coordinates and v is in the rotated frame
% Then we can find the correction u_b - v_b using the relationships
%	u_b - v_b	= u.b - u.Tb
%				= u.(b - Tb)
%				= Tv.(b - Tb)

fprintf(1, 'Pitch/roll rotation.');

% Correct both versions of cov independently
thecov = { 'covs0', 'covs' };

for k = 1:2;
	cov = eval(thecov{k});
	
	J1 = angle(cov(:,:,1))/4;
	J2 = angle(cov(:,:,2))/4;
	J3 = angle(cov(:,:,3))/4;
	J4 = angle(cov(:,:,4))/4;

	v(:,:,1)=[(J1+J2)-(J3+J4)]/x1;
	v(:,:,2)=[(J1+J4)-(J2+J3)]/y1;
	v(:,:,3)=[(J1+J2)+(J3+J4)]/z1;

	deltaV = 0*cov;
	for t = 1:nrecs
		if ~mod(t,120), fprintf(1, '.'); end;

		T = hdssT_HeadingPitchRoll(0, pitch(tds_index,t), roll(tds_index,t));
		V = squeeze(v(:,t,:))';
		deltaV(:,t,:) = ( (T*V).' * ( (eye(3)-T) * B) );
	end

	sonar.(thecov{k}) = cov .* exp(i*deltaV);
end

display('Done.');

