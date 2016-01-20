function PlotSonar(sonar, minDatenum, maxDatenum)

if nargin < 3
	maxDatenum = sonar.datenum(end)
end

if nargin < 2
	minDatenum = sonar.datenum(1)
end

dt = diff(sonar.datenum([2 3]));

plotTimeIndex = find(sonar.datenum >= minDatenum & sonar.datenum <= maxDatenum);

sonarType = strtok(sonar.dasinfo.SonarCom.SonarType','k')

%% Plotting setup variables

plotLengthHours = 48
plotTicksPerDay	= 2;

csound			= 1540		% Sound velocity, (m/s)			

if strcmp(sonarType, '50')
	depthUpper	= 35
	depthLower	= 1000
        %shearScale      = 0.01
	shearScale	= 0.005
	%velScale	= 1
	velScale	= 0.25
    intLims		= [6 14]
    timefilter  = 3

    cutoffdate = 0;
    
elseif strcmp(sonarType, '140')
	depthUpper	= 10
	depthLower	= 350

	%shearScale	= 0.025
	shearScale	= 0.01
	%velScale	= 1
	velScale	= 0.25
    intLims     = [3 10]
    timefilter  = 3
	
	cutoffdate	= 0;
end

logsn_threshold	= 0.2;

fontsize	= 14;
fontweight	= 'normal'

plotAspectRatio = ([3 2 1]);
% dpi = '-r300';
papertype = 'A4';

% Specify a directory where plots will be saved
% plotDir = sprintf('~/Sites/HDSS/%sk', sonarType);
plotDir = 0;	% 0 disables plotting.


%% Process the sonar struct
sonar = ProcessCov(sonar, csound);

%% Compare log10 sn to sn_threshold
sna = log10(sonar.sn) - logsn_threshold;

%% Compute yeardays for the time axis (Midnight Jan 1 = Yearday 1.0)
dv				= datevec(sonar.datenum);
yday			= sonar.datenum - datenum([dv(:,1) ones(length(dv),1) zeros(length(dv),1)])';
plotMinYday		= yday(plotTimeIndex(1))
plotMaxYday		= yday(plotTimeIndex(end))+dt
plotXTick		= [round(plotMinYday*plotTicksPerDay):1:round(plotMaxYday*plotTicksPerDay)]/plotTicksPerDay;

display(['Plotting ' sonarType ' kHz Sonar from ' datestr(minDatenum) ' to ' datestr(maxDatenum+dt) '.']);
close all


%% Intensity
display('Plotting beam intensities.')

figure(1);
beamOrder = [1 4 2 3];

for bi = 1:4
    figure(ceil(bi/2));
    subplot(2,1,2-mod(bi,2));
    
    theBeam = beamOrder(bi);
    
    theInt = squeeze(sonar.int(:,:,theBeam));
    theInt = medfilt2(theInt,[1 timefilter]);
	imagesc(yday, sonar.depths,log10(theInt));
    caxis(intLims);
	colorbar;
% 	axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
% 	datetick('x', 'keeplimits');
	axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
	set(gca,'XTick', plotXTick);
	grid on;
	
	set(gca,'FontSize',fontsize);
	set(gca, 'FontWeight', fontweight);
	title([ sonarType ' kHz: Beam ' num2str(theBeam) ' Intensity (log10) ']);
%     ylabel(['Beam ' num2str(theBeam)]);
    ylabel('Depth (m) ');
	if ~(mod(bi,2))
		xlabel(['Yearday (Last Update: ' datestr(maxDatenum+dt) ' UTC) ']);
		set(gcf,'PaperType',papertype);
		if (plotDir)
			print(dpi, '-dpng', sprintf('%s/intensity%d%d', plotDir, beamOrder(bi-1), beamOrder(bi)));
		end
	end
end

%% Velocity plots
display('Plotting velocities.');

% mean(sonar.TDS.pcode.sog(1:end))/3.6;

U = sonar.U; % sonar.u+ones(length(sonar.depths),1)*1.02*shipnav;
U = medfilt2(real(U),[1 timefilter])+i*medfilt2(imag(U),[1 timefilter]);
% 
gauss2 = gausswin(3)*gausswin(2*timefilter)';
gauss2 = gauss2/sum(sum(gauss2));
U = conv2(U, gauss2, 'same');

% rect1 = ones(1,8);
% rect1 = rect1/sum(rect1);
% U = conv2(U, rect1, 'same');

figure(3);

imagesc(yday, sonar.depths, real(U));
% shading interp; axis ij;
% caxis([-1 1]*7);
caxis([-1 1]*velScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Velocity (m/s)  ']);
		xlabel(['Yearday (Last Update: ' datestr(maxDatenum+dt) ' UTC) ']);
 ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);

% colormap([hsv(16);hsv(16);hsv(16);hsv(16)])
if (plotDir)
	print('-f3', dpi, '-dpng', sprintf('%s/velocity_u', plotDir));
end

figure(4);

imagesc(yday, sonar.depths, imag(U));
% shading interp; axis ij;
caxis([-1 1]*velScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title([sonarType ' kHz: Meridional Velocity (m/s)  ' ]);
xlabel(['Yearday (Last Update: ' datestr(maxDatenum+dt) ' UTC) ']);
 ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);

if (plotDir)
	print('-f4', dpi, '-dpng', sprintf('%s/velocity_v', plotDir));
end

%% Shear plots
display('Plotting shears.');

U_z = sonar.U_z;
U_z = medfilt2(real(U_z),[1 timefilter])+i*medfilt2(imag(U_z),[1 timefilter]);

% rect1 = ones(1,4);
% rect1 = rect1/sum(rect1);
% U_z = conv2(U_z, rect1, 'same');
% 
gauss2 = gausswin(5)*gausswin(2*timefilter)';
gauss2 = gauss2/sum(sum(gauss2));
U_z = conv2(U_z, gauss2, 'same');

figure(5);
% testShadePlot(real(U_z)/(2*shearScale)+1/2, ones(size(U_z)), sna, ...
% 				yday, sonar.depths, timefilter);
% testColorbar(shearScale);
imagesc(yday, sonar.depths, real(U_z));
% shading interp; axis ij;
caxis([-1 1]*shearScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Shear (s ^{-1}) ']);
xlabel(['Yearday (Last Update: ' datestr(maxDatenum+dt) ' UTC) ']);
ylabel('Depth (m) ');
grid on;

set(gcf,'PaperType',papertype);
if (plotDir)
	print('-f5', dpi, '-dpng', sprintf('%s/shear_u', plotDir));
end

figure(6);
% testShadePlot(imag(U_z)/(2*shearScale)+1/2, ones(size(U_z)), sna, ...
% 				yday, sonar.depths, timefilter);
% testColorbar(shearScale);
imagesc(yday, sonar.depths, imag(U_z));
% axis ij; shading interp;
caxis([-1 1]*shearScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Meridional Shear (s ^{-1}) ']);
xlabel(['Yearday (Last Update: ' datestr(maxDatenum+dt) ' UTC) ']);
ylabel('Depth (m) ');
grid on;

set(gcf,'PaperType',papertype);
if (plotDir)
	print('-f6', dpi, '-dpng', sprintf('%s/shear_v', plotDir));
end

%% Beam velocities
% display('Plotting beam covariances.')

beamOrder = [1 4 2 3];

for bi = 1:4
    figure(6+ceil(bi/2));
    subplot(2,1,2-mod(bi,2));
    
    theBeam = beamOrder(bi);
    beamcov = angle(squeeze(sonar.cov(:,:,theBeam)));
    beamcov = medfilt2(beamcov,[1 timefilter]);
% 
% gauss2 = gausswin(3)*gausswin(12)';
% gauss2 = gauss2/sum(sum(gauss2));
% U = conv2(U, gauss2, 'same');

% rect1 = ones(1,8);
% rect1 = rect1/sum(rect1);
% U = conv2(U, rect1, 'same');

    imagesc(yday, sonar.ranges, beamcov);
    caxis([-1 1]*pi);
	colormap(jet);
    colorbar;
%     axis([plotMinDate, plotUpdateTime, sonar.ranges(1), sonar.ranges(end)]);
%     datetick('x', 'keeplimits');
	axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
	set(gca,'XTick', plotXTick);
    set(gca,'FontSize',fontsize);
	set(gca, 'FontWeight', fontweight);
    title([sonarType ' kHz: Beam ' num2str(theBeam) ' arctan(cov)  ']);
    ylabel('Depth (m) ');
    grid on;

	
    if ~(mod(bi,2))
		xlabel(['Last Updated: ' datestr(maxDatenum+dt) ' (UTC) ']);
		set(gcf,'PaperType',papertype);
		if (plotDir)
			print(dpi, '-dpng', sprintf('%s/beam%d%d', plotDir, beamOrder(bi-1), beamOrder(bi)));
		end
	end
end

%% Shaded velocity plot
% display('Plotting shaded velocities.')

% if strcmp(sonarType, '50'),		sn_norm = sna - 0.6;        end;
% if strcmp(sonarType, '140'),	sn_norm = 2*(sna - 0.8);	end;

figure(11);
% testShadePlot((real(U)+1)/2, sna+0.67, 0.8+real(U_z)/(2*shearScale), ...
% 				yday, sonar.depths, timefilter)
testShadePlot((real(U)+1)/2, 1+2*sna, 0.8+imag(U_z)/(2*shearScale),yday, sonar.depths, timefilter)

% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Velocity (m/s)  ']);
xlabel(['Yearday (Last Updated: ' datestr(maxDatenum+dt) ' UTC) ']);
 ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);
if (plotDir)
	print(dpi, '-dpng', sprintf('%s/shadeplot_u', plotDir));
end

figure(12);
% testShadePlot((imag(U)+1)/2, 4*sna, 0.8+imag(U_z)/(2*shearScale), ...
% 				yday, sonar.depths, timefilter)
testShadePlot((imag(U)+1)/2, 1+2*sna, 0.8+imag(U_z)/(2*shearScale),yday, sonar.depths, timefilter)

% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(plotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title([sonarType ' kHz: Meridional Velocity (m/s)  ' ]);
xlabel(['Yearday (Last Updated: ' datestr(maxDatenum+dt) ' UTC) ']);
 ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);
if (plotDir)
	print(dpi, '-dpng', sprintf('%s/shadeplot_v', plotDir));
end
