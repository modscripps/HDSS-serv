function testColorbar(cscale);

cmaplength	= size(colormap,1);
cminor		= 10^floor(log10(cscale));
clabelmin	= -floor(cscale/cminor)*cminor;
clabelmax	= -clabelmin;

cticklabel	= [clabelmin:cminor:clabelmax];

for j = 1:length(cticklabel)
	ctickstr{j} = num2str(cticklabel(j));
end

ctick		= max(round((cticklabel/cscale+1)*cmaplength/2),1);

cbar		= colorbar('YTick',ctick);
set(cbar,'YTickLabel',cticklabel);