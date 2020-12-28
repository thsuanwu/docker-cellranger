# Set the base image
FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /opt/conda/bin:$PATH

# File Author / Maintainer
MAINTAINER thsuanwu@stanford.edu

# Add packages, update image, and clear cache
RUN apt-get update
RUN apt-get install -y apt-utils 
RUN apt-get install -y build-essential wget zip unzip bzip2 git zlib1g-dev pkg-config make libbz2-dev python-pip libncurses-dev liblzma-dev

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN conda config --set always_yes yes --set changeps1 no
RUN conda update -q conda
RUN conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda

RUN conda create --name utilities-env python=3.6 pip
RUN /bin/bash -c "source activate utilities-env"
RUN conda install samtools
RUN conda install awscli-cwlogs
RUN pip install aegea

# Install cellranger 5.0.1
#RUN cd /opt/ && \
	wget -O cellranger-5.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-5.0.1.tar.gz?Expires=1608491037&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci01LjAuMS50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDg0OTEwMzd9fX1dfQ__&Signature=mDpEPGIDLx7cgyp1xIU0eGE43Isla3G9gZzSXoKpEo8HHxOMpcgjJCb2h-pp7dtOSTyclqvICdnld0wnp23B7hOEwhK4IRCB6bqGW3shMWbywF-eht0-vMPS0QymdBZRf07vliIJUwX0yxktw4-ExQWa8eaDgHI8KRkL59HsNwSv~4m3BNl83WH4e99FDTD44IXeiPFywdgWE6LgfcHcHqVXvM6pr7JaQm-is6P1JZHsdtFrb0aVogTgrZOqcWqybZSPAdDUOGd1xjOvTrX~uKW1meqsgUBXZeahOwVWGnK6S1k-Hz7V-oqLs2Xa16lY0nX0RIOXt8pmzzktPjq1AQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \	
	tar -xzvf cellranger-5.0.1.tar.gz && \
	rm -f cellranger-5.0.1.tar.gz

# path
# ENV PATH /opt/cellranger-5.0.1:$PATH

# Taken from: https://github.com/klarman-cell-observatory/cumulus/blob/master/docker/cellranger/5.0.0/Dockerfile
RUN apt-get update && \
    apt-get install --no-install-recommends -y alien unzip build-essential dpkg-dev curl gnupg lsb-release procps python3 python3-pip && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && apt-get install -y google-cloud-sdk=290.0.0-0

RUN pip3 install pandas && \
    pip3 install xlsxwriter

RUN mkdir /software
ADD https://raw.githubusercontent.com/klarman-cell-observatory/cumulus/master/docker/monitor_script.sh /software
ADD cellranger-5.0.0.tar /software

#ADD bcl2fastq2-v2-20-0-linux-x86-64.zip /software/
#RUN unzip -d /software/ /software/bcl2fastq2-v2-20-0-linux-x86-64.zip && alien -i /software/bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm && rm /software/bcl2fastq2-v2*

RUN apt-get -qq -y remove alien curl gnupg python3-pip unzip && \
    apt-get -qq -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log && \
    rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

RUN chmod a+rx /software/monitor_script.sh
ENV PATH=/software:/software/cellranger-5.0.0:$PATH
ENV TMPDIR=/tmp
