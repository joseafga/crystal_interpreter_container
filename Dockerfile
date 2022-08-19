FROM ubuntu:latest

WORKDIR /tmp

# Configure image
RUN apt update && apt install -y \
  automake \
  build-essential \
  git \
  libbsd-dev \
  libedit-dev \
  libevent-dev \
  libgmp-dev \
  libgmpxx4ldbl \
  libpcre3-dev \
  libssl-dev \
  libtool \
  libxml2-dev \
  libyaml-dev \
  lld \
  llvm \
  llvm-dev \
  libz-dev \
  curl \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "deb http://download.opensuse.org/repositories/devel:/languages:/crystal/xUbuntu_22.04/ /" > /etc/apt/sources.list.d/crystal.list \
  && curl -fsSL https://download.opensuse.org/repositories/devel:languages:crystal/xUbuntu_22.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/crystal.gpg > /dev/null \
  && apt update \
  && apt install -y crystal

# Install GC
RUN git clone https://github.com/ivmai/bdwgc.git \
  && cd bdwgc \
  && git clone https://github.com/ivmai/libatomic_ops.git \
  && autoreconf -vif \
  && ./configure --enable-static --disable-shared --prefix=/usr \
  && make -j \
  && make install

# Configure crystal source
WORKDIR /tmp/crystal
# COPY ./crystal-1.5.0.tar.gz /tmp/crystal.tar.gz
RUN curl -L https://github.com/crystal-lang/crystal/archive/refs/tags/1.5.0.tar.gz -o /tmp/crystal.tar.gz
RUN tar -xz -C /tmp/crystal --strip-component=1 -f /tmp/crystal.tar.gz && rm /tmp/crystal.tar.gz

# Build and install
RUN make crystal interpreter=1 \
  && apt remove -y crystal \
  && make install PREFIX=/usr

# Clean
RUN apt clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/crystal", "i"]
