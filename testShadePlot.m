function testShadePlot(H, S, V, X, Y, filtlength)

if nargin < 5
	X = 1:size(H,2);
	Y = 1:size(H,1);
end

cmap = jet(256);
colormap(cmap);
% H = imag(sonar.U);
% S = squeeze(sum(1./sonar.sn, 1));
% V = imag(sonar.U_z);

if nargin < 6
	filtlength = 5;
end

Hsize = size(H);

H = medfilt2(H, [1 filtlength]);
S = medfilt2(S, [1 filtlength]);
V = medfilt2(V, [1 2*filtlength]);

H = max(H, 0);
H = min(H, 1);

H = ind2rgb(round(H*length(cmap)), cmap);
H = rgb2hsv(H);

S = H(:,:,3) .*S;
S (find(imag(S))) = 1;
S = max(S, 0);
S = min(S, 1);

image_depth = 1; % 0.10;
V = H(:,:,3) + V - image_depth/2;
V = max(V, 0);
V = min(V, 1);
V = V.*S;

rgb_image = hsv2rgb(cat(3, H(:,:,1), S, V));

image(X, Y, rgb_image);
pbaspect([16 9 1]);
cbar = colorbar('YTick', [1, [1 2 3 4]/4*length(cmap)]);
set(cbar, 'YTickLabel', {'-1', '-0.5', '0', '0.5', '1'});