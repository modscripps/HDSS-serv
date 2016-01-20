#!/bin/bash -x
#
mutex=~/.hdss-sync
function RmMutex () {
    rm -f $mutex
    exit 0
}

trap RmMutex SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM
if [ ! -e $mutex ]; then
    touch $mutex
else
    echo "already in progress, exiting."
    exit 0
fi

# Local variables
sshKey='/Users/opg/.ssh/hdss-serv_transfer_key'
srcTemplate='/Volumes/*RAID/*_COV/'
date
for freq in 140 50
do
  #  Path on acquisition server to be synced 
    acqPathList=`ssh -i $sshKey hdss-${freq}khz "echo $srcTemplate"`
    	for acqPath in $acqPathList
    	do
    		/usr/bin/rsync -axuve \
			"ssh -axc blowfish -i $sshKey" \
			hdss-${freq}khz:${acqPath} /Volumes/hdssServer_EXT/${freq}k/Covariance/
		done

done

# Launch Matlab.
/Users/opg/HDSS/hdss-serv_domatlab.sh >> /Users/opg/HDSS/serverMatlab.log &
  
# Clean up temp file and mutex
/bin/rm -f $mutex
