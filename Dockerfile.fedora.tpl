FROM #{FROM}

RUN dnf install -y \
		bzip2-devel \
		ca-certificates \
		curl \
		gcc \
		glibc-devel \
		gnupg \
		libsqlite3x-devel \
		make \
		ncurses-devel \
		readline-devel \
		sqlite-devel \
		openssl-devel \
		xz \
		zlib-devel \
		python-devel \
		python3-devel \
	&& dnf clean all

# Install AWS CLI
RUN pip install awscli

COPY build.sh /
