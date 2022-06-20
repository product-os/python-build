#!/bin/bash

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }

# Jenkins build steps
for ARCH in $ARCHS
do
	for PYTHON_VERSION in $PYTHON_VERSIONS
	do
		base_version=${PYTHON_VERSION%.*}

		case $DEBIAN_BUILD_TAG in
			'buster')
				# Debian buster - libffi 3.2
				debian_tag='buster'
				;;
			'bullseye')
				# Debian bullseye - libffi 3.3
				debian_tag='bullseye'
				;;
			*)
				# Debian bookworm - libffi 3.4
				debian_tag='bookworm'
				;;
		esac

		case $ALPINE_BUILD_TAG in
			'3.11')
				# Alpine linux 3.11 - libffi 3.2
				alpine_tag='3.11'
				;;
			'3.13')
				# Alpine linux 3.13 - libffi 3.3
				alpine_tag='3.13'
				;;
			*)
				# Alpine linux 3.15 - libffi 3.4
				alpine_tag='3.15'
				;;
		esac

		template='Dockerfile.debian.python3.tpl'

		case "$ARCH" in
			'armv6hf')
				base_image="balenalib/rpi-raspbian:$debian_tag"
			;;
			'armv7hf')
				base_image="balenalib/armv7hf-debian:$debian_tag"
			;;
			'armel')
				base_image="balenalib/armv5e-debian:$debian_tag"
			;;
			'aarch64')
				base_image="balenalib/aarch64-debian:$debian_tag"
			;;
			'i386')
				base_image="balenalib/i386-debian:$debian_tag"
			;;
			'amd64')
				base_image="balenalib/amd64-debian:$debian_tag"
			;;
			'alpine-armv6hf')
				base_image="balenalib/rpi-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-i386')
				base_image="balenalib/i386-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-amd64')
				base_image="balenalib/amd64-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-aarch64')
				base_image="balenalib/aarch64-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-armv7hf')
				base_image="balenalib/armv7hf-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
		esac
		sed -e s~#{FROM}~$base_image~g $template > Dockerfile
		chmod +x build.sh
		docker build -t python-$ARCH-builder .
		
		docker run --rm -e ARCH=$ARCH \
						-e ACCESS_KEY=$ACCESS_KEY \
						-e SECRET_KEY=$SECRET_KEY \
						-e BUCKET_NAME=$BUCKET_NAME python-$ARCH-builder bash -x build.sh $PYTHON_VERSION
	done
done

# Clean up after every run
docker rmi -f python-$ARCH-builder
