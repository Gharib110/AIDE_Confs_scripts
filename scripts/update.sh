#!/bin/sh

PATH=/usr/bin:/usr/local/bin
export PATH

HOST=$1

ROOTDIR=/usr/local/aide
TARCMD=/usr/local/bin/tar

. $ROOTDIR/DECL

if [ ! -f $ROOTDIR/$HOST.tgz-update ]; then
	echo "Tarball $ROOTDIR/$HOST.tgz-update does not exist!"
	exit 255
fi

cd $ROOTDIR
$TARCMD zxf $HOST.tgz
cd $REM_IDIR
$TARCMD zxf $ROOTDIR/$HOST.tgz-update
mv $REM_NEWDB $REM_ADB
cd $ROOTDIR
$TARCMD zcf $HOST.tgz $REM_IDIR
rm -r $REM_IDIR
