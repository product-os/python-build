FROM #{FROM}

RUN set -x \
	&& buildDeps=' \
		curl \
		gcc \
		bzip2-devel \
		glibc-devel \
		ncurses-devel \
		readline-devel \
		sqlite-devel libsqlite3x-devel \
		openssl-devel \
		make \
		xz \
		zlib-devel \
		python-devel python3-devel ca-certificates gnupg \
	' \
	&& dnf install -y $buildDeps && dnf clean all

# Install AWS CLI
RUN pip install awscli

COPY build.sh /
