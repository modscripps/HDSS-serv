% updateAll is a wrapper to prevent errors from hanging the .hdss-matlab lock

try
	updateMatfiles
	display('Done with updateMatfiles.m.')
catch err
	display(['Error during updateMatfiles.m: ' err.message])
end

try
	updateDisplay
	display('Done with updateDisplay.m.')
catch err
	display(['Error during updateDisplay.m: ' err.message])
end