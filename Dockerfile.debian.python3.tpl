FROM #{FROM}

RUN set -x \
	&& buildDeps=' \
		curl \
		gcc \
		libbz2-dev \
		libbluetooth-dev \
		libc6-dev \
		libncurses-dev \
		libreadline-dev \
		libsqlite3-dev \
		tk-dev \
		tcl-dev \
		libssl-dev \
		liblzma-dev \
		libffi-dev \
		make \
		xz-utils \
		zlib1g-dev \
		python3 python3-dev python3-pip python3-setuptools ca-certificates patch \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN pip install awscli

COPY . /
