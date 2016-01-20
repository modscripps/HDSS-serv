#!/bin/sh
date

# Do the matlab part of HDSS rsync processing.
mutex=/Users/opg/.hdss-matlab
function RmMutex () {
    rm -f $mutex
    exit 0
}

trap RmMutex SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM
if [ ! -e $mutex ]; then
    touch $mutex
else
    echo "HDSS-matlab already in progress, exiting."
    exit 0
fi
# Launch Matlab without its GUI for averaging and output plotting
/Applications/MATLAB_R2010a.app/bin/matlab -nodisplay -nosplash -maci -r \
  "updateAll; quit"
  
# Clean up temp file and mutex
/bin/rm -f $mutex
