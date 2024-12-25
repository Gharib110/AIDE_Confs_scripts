#!/bin/ksh

PATH=/usr/bin:/usr/local/bin
export PATH

# Command line args "check hostname [port [tarcmd]]
#
HOST=$1				# hostname to check ([ -f $ROOTDIR/$HOST.tgz ])
PORT=${2:-22}			# can specify alternate port for SSH daemon
REMTARCMD=${3:-/bin/tar}	# path to GNU tar on remote machine

# Local pathname definitions
#
ROOTDIR=/usr/local/aide		# where tarballs live on local system
TEMPFILE=$ROOTDIR/.run$$	# temp file to use for output

# Pick up other settings
. $ROOTDIR/DECL


if [ ! -f $ROOTDIR/$HOST.tgz ]; then
	echo "Tarball $ROOTDIR/$HOST.tgz does not exist!"
	exit 255
fi

cp /dev/null $TEMPFILE

scp -P $PORT $ROOTDIR/$HOST.tgz ${HOST}:$REM_DIR/$REM_ARCH >>$TEMPFILE 2>&1
ssh -p $PORT $HOST "(cd $REM_DIR; \
                     $REMTARCMD zxfp $REM_ARCH; \
                     cd $REM_IDIR; \
                     ./$REM_CMD --config=./$REM_CONF --update; \
                     $REMTARCMD zcf $REM_ARCH $REM_NEWDB)" >>$TEMPFILE 2>&1
scp -P $PORT ${HOST}:$REM_DIR/$REM_IDIR/$REM_ARCH $ROOTDIR/$HOST.tgz-update \
        >>$TEMPFILE 2>&1
ssh -p $PORT $HOST /bin/rm -rf $REM_DIR/$REM_IDIR $REM_DIR/$REM_ARCH \
	>>$TEMPFILE 2>&1

if [ ! "`grep '### All files match AIDE database.  Looks okay!' $TEMPFILE`" ]
then
	awk "!/^Authorized/ && !/^$HOST.tgz:/ { print }" $TEMPFILE
fi
rm $TEMPFILE
