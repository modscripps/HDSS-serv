function updateDisplay

sonarsToPlot	= {'50', '140'};
% sonarsToPlot	= {'50'};


%%
for si = 1:length(sonarsToPlot)
	sonarType = sonarsToPlot{si}

%     sonarType = '140'
%% Plotting setup variables

plotLengthHours = 72
plotTicksPerDay	= 2
profilePlotMinutes = 15;

csound			= 1540		% Sound velocity, (m/s)			

if strcmp(sonarType, '50')
	depthUpper	= 35
	depthLower	= 1200

	%shearScale	= 0.012
	shearScale	= 0.005
	%velScale	= 1.0
	velScale	= 0.35
    intLims     = [6 14]
    timefilter  = 5
	sn_threshold	= 0.25
	profileSNthreshold = 0.55;

    cutoffdate = 0;
	
	UmeanRange   = [175 700];	% Depth range to calculate Umean
    
elseif strcmp(sonarType, '140')
	depthUpper	= 10
	depthLower	= 400

	%shearScale	= 0.036
	shearScale	= 0.012
	%velScale	= 1.1
	velScale	= 0.35
    intLims     = [4 12]
    timefilter  = 3
	sn_threshold	= 0.0
	profileSNthreshold = 0.4
	
	cutoffdate	= 0;
	
	UmeanRange   = [25 175];	% Depth range to calculate Umean
end

profilerFallRate = 0.50;	% m/s, used to estimate profiler drift

avgTimeSecs		= 60;       % This specifies the averaged mat-files which are plotted
% avgTimeMins		= 1;	% Deprecated, used to be specified in mins

fontsize	= 14;
fontweight	= 'bold'

singlePlotAspectRatio = ([3 2 1]);
dpi = '-r72';
papertype = 'A3';
custom_cmap = rwb;
zeroNaNs	= 1;

% dataVolume	= '/Volumes/O2/hdssServer_Ext';
dataVolume	= '/Volumes/hdssServer_Ext';
matDir		= sprintf('%s/%sk/Matfiles', dataVolume, sonarType);
plotDir		= sprintf('~/Sites/HDSS/%sk', sonarType);	% 0 to disable saving


% Get time references 
plotUpdateTime = now;
plotMinDate		= plotUpdateTime - plotLengthHours/24;
today			= floor(plotUpdateTime); 
daysBackToLoad	= today - fix(plotMinDate);

%% Load and concatenate the Matfiles
clear sonarcat;

fileCount = 0;

for theDatenum = today:-1:today-daysBackToLoad
	theMatFile = sprintf('%s/%sk_%s_%ds.mat', ...
					matDir, sonarType, datestr(theDatenum, 29), avgTimeSecs);
	if exist(theMatFile, 'file')
		display(['Loading ' theMatFile]);
 		load(theMatFile);
		if exist('sonar')
			if exist('sonarcat')
				sonarcat = CatSonar(sonar, sonarcat);
			else
				sonarcat = sonar;
			end
		end
	else
		display(['Matfile not found: ' theMatFile]);
		if exist('sonarcat')
			break;
		else
			continue;
        end
	end;
end

if exist('sonarcat')
	sonar = sonarcat
else
	error('No Matfiles found in the time range.')
end

%%
sonar = ProcessCov(sonar, csound);
datapoints = find(~isnan(sonar.TDS.time_mark));

plotTimeIndex	= find(sonar.datenum < plotUpdateTime ...
						& sonar.datenum >= plotMinDate & ~isnan(sonar.TDS.time_mark));
plotMaxTime		= sonar.datenum(plotTimeIndex(end)) + avgTimeSecs/86400;
% plotMaxTime		= sonar.datenum(plotTimeIndex(end)) + avgTimeMins/1440;
plotMinDate		= sonar.datenum(plotTimeIndex(1));

% Compute yeardays for the time axis (Midnight Jan 1 = Yearday 1.0)
dv				= datevec(sonar.datenum);
yday			= sonar.datenum - datenum([dv(1,1) 1 0])';
                                    % This was changed to 1,1,1 for some
                                    % reason, changed to 1,1,0 to
                                    % restore correct yearday
                                    % -osun, 2013-04-28
                                   
plotMinYday		= yday(plotTimeIndex(1))
plotMaxYday		= yday(plotTimeIndex(end))
plotXTick		= [round(plotMinYday*plotTicksPerDay):1:round(plotMaxYday*plotTicksPerDay)]/plotTicksPerDay;

display(['Plotting ' sonarType ' kHz Sonar from ' datestr(plotMinDate) ' to ' datestr(plotMaxTime) '.']);
close all

%% Compute s/n average from cov and int
sn = abs(sonar.cov)./(sonar.int-abs(sonar.cov));
sna = log10(sum(sn, 3)/4);
% sna = 1./(1 + exp(-16*(sna - sn_threshold)));
sna = sna - sn_threshold;


%% Intensity
% display('Plotting beam intensities.')

figure(1);
beamOrder = [1 4 2 3];

for bi = 1:4
    figure(ceil(bi/2));
    subplot(2,1,2-mod(bi,2));
    
    theBeam = beamOrder(bi);
    
    theInt = squeeze(sonar.int(:,:,theBeam));
    %theInt = squeeze(sonar.covs(:,:,theBeam));
%     theInt = medfilt2(theInt,[1 timefilter]);
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
        xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
		set(gcf,'PaperType',papertype);
		if (plotDir)
			print(dpi, '-dpng', sprintf('%s/intensity%d%d', plotDir, beamOrder(bi-1), beamOrder(bi)));
		end
	end
end

%% Velocity plots
% display('Plotting velocity.');

% mean(sonar.TDS.pcode.sog(1:end))/3.6;

U = sonar.U; % sonar.u+ones(length(sonar.depths),1)*1.02*shipnav;
U(find(sna < sn_threshold)) = NaN; % S/N filtering

NaNs = find(isnan(U));
U(NaNs) = 0;
U = medfilt2(real(U),[1 timefilter])+i*medfilt2(imag(U),[1 timefilter]);
% 
gauss2 = gausswin(3)*gausswin(timefilter)';
gauss2 = gauss2/sum(sum(gauss2));
U = conv2(U, gauss2, 'same');

if ~zeroNaNs
	U(NaNs) = NaN + i*NaN;
end

% rect1 = ones(1,8);
% rect1 = rect1/sum(rect1);
% U = conv2(U, rect1, 'same');

if ~zeroNaNs
	U(NaNs) = NaN + i*NaN;
end

figure(3);

imagesc(yday, sonar.depths, real(U));
% shading interp; axis ij;
% caxis([-1 1]*7);
caxis([-1 1]*velScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(singlePlotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Velocity (m/s)  ']);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);

colormap(custom_cmap);
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
pbaspect(singlePlotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title([sonarType ' kHz: Meridional Velocity (m/s)  ' ]);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);

colormap(custom_cmap);

if (plotDir)
	print('-f4', dpi, '-dpng', sprintf('%s/velocity_v', plotDir));
end

%% Shear plots
% display('Plotting shear.');

U_z = sonar.U_z;
U_z(find(sna < sn_threshold)) = NaN; % S/N filtering

NaNs = find(isnan(U_z));
U_z(NaNs) = 0;
U_z = medfilt2(real(U_z),[1 timefilter])+i*medfilt2(imag(U_z),[1 timefilter]);

% rect1 = ones(1,4);
% rect1 = rect1/sum(rect1);
% U_z = conv2(U_z, rect1, 'same');
% 
gauss2 = gausswin(5)*gausswin(timefilter)';
gauss2 = gauss2/sum(sum(gauss2));
U_z = conv2(U_z, gauss2, 'same');

if ~zeroNaNs
	U_z(NaNs) = NaN + i*NaN;
end

figure(5);
% testShadePlot(real(U_z)/(2*shearScale)+1/2, ones(size(U_z)), sna, ...
% 				yday, sonar.depths, timefilter);
% testColorbar(shearScale);
imagesc(yday, sonar.depths, real(U_z));
% shading interp; axis ij;
caxis([-1 1]*shearScale);
colorbar;
% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(singlePlotAspectRatio);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Shear (s ^{-1}) ']);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;

colormap(custom_cmap);
% colormap(colCogSc(64));

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
pbaspect(singlePlotAspectRatio);
% datetick('x', 'keeplimits');
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Meridional Shear (s ^{-1}) ']);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;
% colormap(colCogSc(64));
colormap(custom_cmap);

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

	
	colormap(custom_cmap);
	
    if ~(mod(bi,2))
        xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
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

U = sonar.U; % sonar.u+ones(length(sonar.depths),1)*1.02*shipnav;
U(find(sna < sn_threshold)) = NaN; % S/N filtering

NaNs = find(isnan(U));
U(NaNs) = 0;
U = medfilt2(real(U),[1 timefilter])+i*medfilt2(imag(U),[1 timefilter]);
% 
gauss2 = gausswin(3)*gausswin(timefilter)';
gauss2 = gauss2/sum(sum(gauss2));
U = conv2(U, gauss2, 'same');

% if ~zeroNaNs
	U(NaNs) = NaN + i*NaN;
% end

NaNs = find(isnan(U_z));
U_z(NaNs) = 0;

figure(11);
% testShadePlot((real(U)+1)/2, sna+0.67, 0.8+real(U_z)/(2*shearScale), ...
% 				yday, sonar.depths, timefilter)
testShadePlot((real(U)+1)/2, 1+2*sna, 0.8+imag(U_z)/(2*shearScale),yday, sonar.depths, timefilter)

% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(singlePlotAspectRatio);
%colormap(redblue(64));
%caxis([-1 1]*velScale);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', fontweight);
title([sonarType ' kHz: Zonal Velocity (m/s)  ']);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);
if (plotDir)
	print(dpi, '-dpng', sprintf('%s/shadeplot_u', plotDir));
end

figure(12);
% testShadePlot((imag(U)+1)/2, 4*sna, 0.8+imag(U_z)/(2*shearScale), ...
% 				yday, sonar.depths, timefilter)
testShadePlot((imag(U)+1)/2, 1+2*sna, 0.8+imag(U_z) /(2*shearScale),yday, sonar.depths, timefilter)

% axis([plotMinDate, plotUpdateTime, depthUpper, depthLower]);
pbaspect(singlePlotAspectRatio);
%colormap(redblue(64));
%caxis([-1 1]*velScale);
% datetick('x', 'keeplimits');
axis([plotMinYday, plotMaxYday, depthUpper, depthLower]);
set(gca,'XTick', plotXTick);
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title([sonarType ' kHz: Meridional Velocity (m/s)  ' ]);
xlabel({'Yearday', ['(Last Updated: ' datestr(sonar.datenum(plotTimeIndex(end)), 'dd-mmm-yyyy HH:MM') ' UTC) ']});
ylabel('Depth (m) ');
grid on;
set(gcf,'PaperType',papertype);
if (plotDir)
	print(dpi, '-dpng', sprintf('%s/shadeplot_v', plotDir));
end

%% Profile plots
% Compute with some time history 
profileHistoryHoursBack = 6;

U_profile = zeros(size(sonar.U(:,1:profileHistoryHoursBack+1)));
U_z_profile = zeros(size(sonar.U_z(:,1:profileHistoryHoursBack+1)));

profileSNmask = ones(size(sonar.sn));
profileSNmask(find(log10(sonar.sn) < profileSNthreshold)) = NaN;

	
profileTimeIndex = plotTimeIndex(find(sonar.datenum(plotTimeIndex) >= sonar.datenum(plotTimeIndex(end)) - profilePlotMinutes/1440));

int_profile = squeeze(nanmean(sonar.int(:,profileTimeIndex,:), 2));
%int_profile = squeeze(nanmean(sonar.covs(:,profileTimeIndex,:), 2));
sn_profile  = squeeze(nanmean(sn(:,profileTimeIndex,:), 2));
				
for hoursBack = 0:profileHistoryHoursBack	 % get history of U and U_z for future use
	profileTimeIndex = plotTimeIndex(find(sonar.datenum(plotTimeIndex) <= sonar.datenum(plotTimeIndex(end)) - hoursBack/24 ...
						& sonar.datenum(plotTimeIndex) >= sonar.datenum(plotTimeIndex(end)) - hoursBack/24 - profilePlotMinutes/1440));

	U_profile(:,hoursBack+1) = nanmean(sonar.U(:,profileTimeIndex).*profileSNmask(:,profileTimeIndex),2);
	U_z_profile(:,hoursBack+1) = nanmean(sonar.U_z(:,profileTimeIndex).*profileSNmask(:,profileTimeIndex),2);
end

profileAspect = [1 2 1];
%

figure(21);
subplot(1,2,1);
U_profile(find(isnan(U_profile))) = NaN + i*NaN;
plot(real(U_profile(:,1)),sonar.depths,imag(U_profile(:,1)),sonar.depths, 'LineWidth', 2)
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title('Velocity');
legend('U', 'V', 'Location', 'SouthEast');
ylabel('Depth (m) ')
xlabel(sprintf('Velocity (m/s), %2.1f-min avg.', profilePlotMinutes));
ylim([depthUpper depthLower]);
xlim([-1 1]*velScale);
hold on; plot([0 0], [depthUpper depthLower],'k'); hold off;
axis ij; grid
pbaspect(profileAspect)


subplot(1,2,2);
U_z_profile(find(isnan(U_z_profile))) = NaN + i*NaN;
plot(real(U_z_profile(:,1)),sonar.depths,imag(U_z_profile(:,1)),sonar.depths, 'LineWidth', 2)
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title('Shear');
legend('dU/ dz', 'dV/ dz', 'Location', 'SouthEast');
ylabel('Depth (m) ')
xlabel(sprintf('Shear (s^{-1}), %2.1f-min avg.', profilePlotMinutes));
ylim([depthUpper depthLower]);
xlim([-1 1]*shearScale);
hold on; plot([0 0], [depthUpper depthLower],'k'); hold off;
axis ij; grid
pbaspect(profileAspect)

if (plotDir)
	print(dpi, '-dpng', sprintf('%s/profiles_vel-shear', plotDir));
end

figure(22);
subplot(1,2,1);
plot(log10(int_profile), sonar.depths, ...
        log10(nanmean(int_profile,2)), sonar.depths, 'k-', 'LineWidth', 2)
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title(sprintf('Backscatter Intensity'))
legend('b1', 'b2', 'b3', 'b4', 'Avg.', 'Location', 'SouthEast');
% legend('Beam 1', 'Beam 2', 'Beam 3', 'Beam 4', 'Avg.', 'Location', 'SouthEast');
ylabel('Depth (m) ')
xlabel(sprintf('log_{10} Intensity, %2.1f-min avg.', profilePlotMinutes));
ylim([depthUpper depthLower]);
xlim(intLims)
axis ij; grid
pbaspect(profileAspect)

subplot(1,2,2);
plot(log10(sn_profile), sonar.depths, ...
        log10(nanmean(sn_profile,2)), sonar.depths, 'k-', 'LineWidth', 2)
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title(sprintf('Signal-to-Noise Ratio'))
legend('b1', 'b2', 'b3', 'b4', 'Avg.', 'Location', 'SouthEast');
% legend('Beam 1', 'Beam 2', 'Beam 3', 'Beam 4', 'Avg.', 'Location', 'SouthEast');
ylabel('Depth (m) ')
xlabel(sprintf('log_{10} S/N, %2.1f-min avg.', profilePlotMinutes));
ylim([depthUpper depthLower]);
axis ij; grid
pbaspect(profileAspect)

if (plotDir)
	print(dpi, '-dpng', sprintf('%s/profiles_int-sn', plotDir));
end

%% Mean current vector

Umean_upper = find(sonar.depths >= UmeanRange(1), 1, 'first');
Umean_lower = find(sonar.depths <= UmeanRange(2), 1, 'last');


Umean = nanmean(U_profile(Umean_upper:Umean_lower,:),1);
Umean_scale = ceil(max(abs(Umean))*10)/10;
% Umean_scale = ceil(max(abs(real(Umean)),abs(imag(Umean)))*10)/10;
if isnan(Umean_scale), Umean_scale = 1.0; end;

Heading  = mod(90-angle(Umean)*180/pi - 360,360);

figure(23);
hold on;
for hoursBack = profileHistoryHoursBack:-1:1
	quiver(0, 0, real(Umean(hoursBack+1)), imag(Umean(hoursBack+1)), 0,...
		'LineWidth', 3, 'Color', [1 1 1]*(0.3+0.6*hoursBack/profileHistoryHoursBack));
% 		'LineWidth', 3, 'Color', [1 1 1]*0.9*(1-1/2^hoursBack));
end
plot([0 0], [-1 1]*Umean_scale, '-k', [-1 1]*Umean_scale, [0 0], '-k');
plot(abs(Umean(1))*cosd([1:360]), abs(Umean(1))*sind([1:360]), '-k');
quiver(0, 0, real(Umean(1)), imag(Umean(1)), 0, 'r', 'LineWidth', 3);
hold off;
axis([-1 1 -1 1]*Umean_scale); axis square; grid
set(gca,'FontSize',fontsize);
set(gca, 'FontWeight', 'bold');
title(sprintf('Mean Currents for Last %d Hours, %3.0f - %3.0f m Depth Range', profileHistoryHoursBack, UmeanRange(1), UmeanRange(2) ))
xlabel(sprintf('Magnitude: %6.2f cm/s, Heading: %6.2f deg \n Profiler drift based on fall rate of %4.2f m/s: %6.2f m', ...
	abs(Umean(1))*100, Heading(1), profilerFallRate, diff(UmeanRange)/profilerFallRate*2*abs(Umean(1))))
ylabel('Current Velocity (m/s)')

if (plotDir)
	print(dpi, '-dpng', sprintf('%s/umean', plotDir));
end

%%
end

%%
end		% for si = 1:length(sonarsToPlot)
