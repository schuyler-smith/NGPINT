FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    ca-certificates \
    wget curl \
    zip unzip gzip \
    make autoconf automake pkg-config build-essential \
    zlib1g-dev libbz2-dev libltdl-dev libtool \
    libcurl4-openssl-dev \
    libxml2-dev \
    libgdal-dev \
    libssl-dev \
    default-jre-headless \
    perl \
    python3-dev python3-pip \
    r-base r-base-core r-base-dev \
    git \
  && apt-get upgrade --yes \
  && apt-get clean
  
RUN pip install ruffus

RUN apt-get install --no-install-recommends --yes \
    locales \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8
  ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

COPY ./R_install /tmp/R_install
RUN /tmp/R_install/install2.r --error --skipinstalled \
    BiocManager \
  && /tmp/R_install/installBioc.r --error --skipinstalled --deps \
    DESeq2

WORKDIR /opt
ENV PATH ${PATH}:/opt/

ARG PROGRAM="Trimmomatic"
ARG VERSION="0.39"
RUN wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-${VERSION}.zip \
    -O ${PROGRAM}.zip \
    && unzip ${PROGRAM}.zip \
    && rm -rf ${PROGRAM}.zip \
    && echo '#!/bin/bash' > trimmomatic \
    && echo "java -jar ${PWD}/${PROGRAM}-${VERSION}/trimmomatic-${VERSION}.jar \${@}" >> trimmomatic \
    && chmod +x trimmomatic \
    && cp -r ${PROGRAM}-${VERSION}/adapters ./

# STAR
ARG VERSION="2.7.9a"
RUN wget https://github.com/alexdobin/STAR/archive/${VERSION}.zip \
  && unzip ${VERSION}.zip \
  && rm ${VERSION}.zip \
  && make -C STAR-${VERSION}/source STAR STARlong
ENV PATH ${PATH}:/opt/STAR_${VERSION}/STAR-${VERSION}/bin/Linux_x86_64

# Samtools
ARG VERSION="1.14"
RUN wget https://github.com/samtools/samtools/releases/download/${VERSION}/samtools-${VERSION}.tar.bz2 \
  && tar jxf samtools-${VERSION}.tar.bz2 \
  && rm samtools-${VERSION}.tar.bz2 \
  && make -C samtools-${VERSION} \
  && make -C samtools-${VERSION} install

# Salmon
ARG VERSION="1.5.2"
RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v${VERSION}/salmon-${VERSION}_linux_x86_64.tar.gz \
  && tar xzf salmon-${VERSION}_linux_x86_64.tar.gz \
  && rm salmon-${VERSION}_linux_x86_64.tar.gz
ENV PATH ${PATH}:/opt/salmon-${VERSION}_linux_x86_64/bin/

# gffread
ARG VERSION="0.12.7"
RUN wget https://github.com/gpertea/gffread/releases/download/v${VERSION}/gffread-${VERSION}.Linux_x86_64.tar.gz \
  && tar xzf gffread-${VERSION}.Linux_x86_64.tar.gz \
  && rm gffread-${VERSION}.Linux_x86_64.tar.gz
ENV PATH ${PATH}:/opt/gffread-${VERSION}.Linux_x86_64/

# NGPINT
ARG VERSION="1.0.0"
RUN wget https://github.com/Wiselab2/NGPINT/archive/refs/tags/NGPINTv${VERSION}.tar.gz \
  && tar -xzf NGPINTv${VERSION}.tar.gz \
  && rm NGPINTv${VERSION}.tar.gz



CMD ["/bin/bash"]