#!/bin/bash
cp -p /Users/opg/HDSS/*.m /Users/scientist/HDSS
cp -p /Users/opg/HDSS/hdss-user_script.sh /Users/scientist/HDSS
#rm /Users/scientist/HDSS/*.old

chown -R scientist /Users/scientist/HDSS

cp -pR /Users/opg/Sites/HDSS /Users/scientist/Sites
chown -R scientist /Users/scientist/Sites/HDSS
