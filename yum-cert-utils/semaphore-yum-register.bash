#!/bin/bash

MYPWD=$PWD
WHOAMI=`whoami`
OUTDIR=/tmp/semaphore-$WHOAMI
read -p "Enter fullname: " FULLNAME

mkdir -p $OUTDIR
echo "User: $FULLNAME" > $OUTDIR/userinfo.txt

openssl genrsa 2048 > /tmp/semaphore-yum.key
chmod 400 /tmp/semaphore-yum.key
openssl req -new -x509 -nodes -sha256 -days 3650 -key /tmp/semaphore-yum.key -out /tmp/semaphore-yum.cert
chmod 400 /tmp/semaphore-yum.cert

EXPIRY=`openssl x509 -enddate -noout -in /tmp/semaphore-yum.cert`
cp /tmp/semaphore-yum.cert $OUTDIR
echo "Expiry: " $EXPIRY >> $OUTDIR/userinfo.txt

cd /tmp
tar cvf semaphore-$WHOAMI.tar semaphore-$WHOAMI/
cd $MYPWD
