FROM #{FROM}

RUN set -x \
	&& buildDeps=' \
		bluez-dev \
		curl \
		gcc \
		libbz2 \
		musl-dev \
		ncurses5-libs \
		readline-dev \
		sqlite-dev \
		openssl-dev \
		make \
		xz \
		zlib-dev \
		ncurses-dev \
		bzip2-dev \
		gdbm-dev \
		libffi-dev \
		xz-dev \
		linux-headers \
		paxmark \
		py-pip \
		gnupg \
		coreutils \
	' \
	&& apk add --no-cache $buildDeps

# Install AWS CLI
RUN pip install awscli

COPY . /
