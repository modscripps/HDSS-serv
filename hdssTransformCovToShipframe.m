function sonar = TransformCovToShipframe(sonar, csound)
% Transform VRU-corrected covariance 'covs' to beamvel and u(ship)

% Need a nominal csound in m/s
if nargin < 2
	if isfield(sonar,'csound')
		csound = sonar.csound;
	else
		csound = 1490;
	end	
end
% Sal = 34;	% psu

% Get array dimensions
[nbins nrecs nbeams] = size(sonar.cov);

% Test beam vectors (optimized for 50 kHz, Cape Town 2009)
% Az   = pi/4 - 2.3*pi/180;	  % -42.7045 * pi/180; 
% De = -pi/3 + 1.3*pi/180;  % 58.6561 * pi/180; 
% [x1 y1 z1] = sph2cart(Az, -De, 1);

% Ship coordinate system is x = bow, y = port beam, z = up
% b1 = [x1 y1 z1];
% b2 = [x1 -y1 z1];
% b3 = [-x1 -y1 z1];
% b4 = [-x1 y1 z1];
% B  = [b1; b2; b3; b4];

% from covparams.c:
% //	float	azim50[4]	= { 317.331944, 42.800278, 136.790556, 222.134444 },
% //			depr50[4]	= { 59.472222, 57.982500, 58.783889, 58.379167 },
% //			
% //			azim140[4]	= { 317.220000, 44.549722, 136.275556, 223.153056 },
% //			depr140[4]	= { 59.550278, 59.540278, 58.798889, 58.892778 };

SonarType = sonar.dasinfo.SonarCom.SonarType(1:3)';

if strcmp(SonarType,'50k')
	Az= 2*pi - [ 317.331944, 42.800278, 136.790556, 222.134444 ]' * pi/180;
	De = [ 59.472222, 57.982500, 58.783889, 58.379167]' * pi/180;	
elseif strcmp(SonarType,'140')
	Az = 2*pi - [317.220000, 44.549722, 136.275556, 223.153056 ]' * pi/180;
	De = [ 59.550278, 59.540278, 58.798889, 58.892778 ]' * pi/180;
end

% Ship coordinate system is x = bow, y = port beam, z = up
[x y z] = sph2cart(Az, -De, 1);
B  = [x y z];

% Covariance stuff
dt = sonar.dasinfo.SonarCom.sample_period/1e6;
tau = dt*sonar.dasinfo.time_lag;
fxmit = sonar.dasinfo.SonarCom.xmitfreq;
v_coeff = csound / (4 * pi * fxmit *tau);

display('Beam velocities.');

sonar.nbins		= sonar.dasinfo.n_bins;
sonar.ranges	= dt*sonar.dasinfo.range_average*[0:sonar.nbins-1]'*csound/2;
sonar.depths	= abs(z(1)) * sonar.ranges;


% sonar 
if strcmp(SonarType,'50k')
    disp('Beam correction new in 2012')
    load CorrectionC
     sonar = hdssBeampatternCorr(sonar,aSM,depthC);
elseif strcmp(SonarType,'140')
   disp('Skipping scattering correction on 140khz')
    sonar.covb = sonar.covs; % make fake "corrected" covariance data
end

display('Transform to ship coordinates.');
sonar.beamvel	= angle(sonar.covb) * v_coeff;
sonar.beamvelxx	= angle(sonar.covs) * v_coeff;

v = zeros(nbins,nrecs,3);
for di = 1:nbins
	% Negative sign because beam velocities are positive-in
	v(di,:,:) = -(B\squeeze(sonar.beamvel(di,:,:))')';
	vxx(di,:,:) = -(B\squeeze(sonar.beamvelxx(di,:,:))')';
end

sonar.u = squeeze(v(:,:,1) + i*(v(:,:,2)));
sonar.w = squeeze(v(:,:,3));

sonar.u_z = conv2(sonar.u,[1 0 -1]','same')./repmat(conv2(sonar.depths,[1 0 -1]','same'),[1 nrecs]);

sonar.uxx = squeeze(vxx(:,:,1) + i*(vxx(:,:,2)));
sonar.wxx = squeeze(vxx(:,:,3));

sonar.u_zxx = conv2(sonar.uxx,[1 0 -1]','same')./repmat(conv2(sonar.depths,[1 0 -1]','same'),[1 nrecs]);

% Save the uncorrected beamvels in sonar for diagnostic purposes.
sonar.beamvel	= angle(sonar.covb) * v_coeff;
sonar.beamvelxx	= angle(sonar.covs) * v_coeff;

return