#!/bin/bash

# Jenkins build steps

for ARCH in $ARCHS
do
	for PYTHON_VERSION in $PYTHON_VERSIONS
	do
		base_version=${PYTHON_VERSION%.*}
		case "$ARCH" in
			'armv6hf')
				sed -e s~#{FROM}~resin/rpi-raspbian:wheezy~g Dockerfile.debian.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~''~g build.tpl > build.sh
			;;
			'armv7hf')
				sed -e s~#{FROM}~resin/armv7hf-debian:wheezy~g Dockerfile.debian.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~''~g build.tpl > build.sh
			;;
			'armel')
				sed -e s~#{FROM}~resin/armel-debian:wheezy~g Dockerfile.debian.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~''~g build.tpl > build.sh
			;;
			'i386')
				sed -e s~#{FROM}~resin/i386-debian:wheezy~g Dockerfile.debian.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~''~g build.tpl > build.sh
			;;
			'amd64')
				sed -e s~#{FROM}~resin/amd64-debian:wheezy~g Dockerfile.debian.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~''~g build.tpl > build.sh
			;;
			'alpine-armhf')
				sed -e s~#{FROM}~resin/armhf-alpine:latest~g Dockerfile.alpine.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~"paxmark -zm /python/usr/local/bin/python$base_version"~g build.tpl > build.sh
			;;
			'alpine-i386')
				sed -e s~#{FROM}~resin/i386-alpine:latest~g Dockerfile.alpine.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~"paxmark -zm /python/usr/local/bin/python$base_version"~g build.tpl > build.sh
			;;
			'alpine-amd64')
				sed -e s~#{FROM}~resin/amd64-alpine:latest~g Dockerfile.alpine.tpl > Dockerfile
				sed -e s~#{ALPINE_ONLY}~"paxmark -zm /python/usr/local/bin/python$base_version"~g build.tpl > build.sh
			;;
		esac
		chmod +x build.sh
		docker build -t python-$ARCH-builder .
		
		docker run --rm -e ARCH=$ARCH \
						-e ACCESS_KEY=$ACCESS_KEY \
						-e SECRET_KEY=$SECRET_KEY \
						-e BUCKET_NAME=$BUCKET_NAME python-$ARCH-builder bash build.sh $PYTHON_VERSION
	done
done

# Clean up after every run
docker rmi -f python-$ARCH-builder
