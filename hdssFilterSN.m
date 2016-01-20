function sonar = hdssFilterSN(sonar, snThreshold)

if nargin<2, snThreshold = -0.5; end;

ti=[1:size(sonar.cov,2)];
S  = abs(sonar.cov);
sn = log10(S./abs(sonar.int-S));
int_mean = repmat(nanmean(sonar.int(:,ti,:),2),[1,length(ti),1]);

snmask = ones(size(sn));
snmask(sn < snThreshold) = NaN;
snmask(sonar.int > 10*int_mean) = NaN;

S0 = abs(sonar.cov0);
sn0 = log10(S0./abs(sonar.int0-S0));
int_mean0 = repmat(nanmean(sonar.int0(:,ti,:),2),[1,length(ti),1]);

snmask0 = ones(size(sn0));
snmask0(sn0 < snThreshold) = NaN;
snmask0(sonar.int0 > 10*int_mean0) = NaN;
%%
% figure(1);
% imagesc(sn(:,:,1));
% caxis([0 1]); colorbar
% 
% figure(2);
% imagesc(sn0(:,:,1));
% caxis([0 1]); colorbar

% figure(3);
% imagesc(snmask(:,:,1));
% caxis([0 1]); colorbar
% 
% figure(4);
% imagesc(snmask0(:,:,1));
% caxis([0 1]); colorbar

%%
sonar.cov = sonar.cov .*snmask;
sonar.int = sonar.int .*snmask;
if isfield(sonar,'covs'), sonar.covs = sonar.covs .*snmask; end;

sonar.cov0 = sonar.cov0 .*snmask0;
sonar.int0 = sonar.int0 .*snmask0;
if isfield(sonar,'covs0'), sonar.covs0 = sonar.covs0 .*snmask0; end;