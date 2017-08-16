#!/bin/bash
set -e
set -o pipefail

gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 26DEA9D4613391EF3E25C9FF0A5B101836580288
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D


# set env var
PYTHON_VERSION=$1
TAR_FILE=Python-$PYTHON_VERSION.linux-$ARCH.tar.gz
BUCKET_NAME=$BUCKET_NAME

mkdir -p /usr/src/python
curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz
curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc
gpg --verify python.tar.xz.asc
tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz
rm python.tar.xz*
cd /usr/src/python

# this patch also works for v3.3.6
# https://github.com/coreos/coreos-overlay/blob/master/dev-lang/python-oem/files/python-2.7-aarch64-fix.patch
if [ $ARCH == "aarch64" ] && [ $PYTHON_VERSION == "3.3.6" ]; then
	patch -p1 < /patches/$ARCH-$PYTHON_VERSION.patch
fi

./configure --enable-shared --enable-unicode=ucs4
make -j$(nproc)
make -j$(nproc) DESTDIR="/python" install
cd /
tar -cvzf $TAR_FILE python/*

curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt"
sha256sum $TAR_FILE >> SHASUMS256.txt

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp $TAR_FILE s3://$BUCKET_NAME/python/v$PYTHON_VERSION/
aws s3 cp SHASUMS256.txt s3://$BUCKET_NAME/
