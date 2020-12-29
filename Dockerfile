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
RUN cd /opt/ && \
	wget -O cellranger-5.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-5.0.1.tar.gz?Expires=1609218020&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci01LjAuMS50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDkyMTgwMjB9fX1dfQ__&Signature=PCPHUVLWye~Q1H8xA955lrMR2zYYwlbEezqJJxAkHUVb~OqLz8pmb-32gLvPg833EbeTfn4KNK7Jm9H4PY0skAbrLRYE1xjRyk0QkF4ZKL3AnOyCr3IhIGqsxicCnTPXNcn5q3rH2dWb1HAiPcodsbdz~58TcjfcYCfIySzAhrmui0BIClwy417XaUbITqQXxWJ1MPAcxzf086J8xiaDle0ARUZfBkqYf8QQzunBiAQux4ywiNazYoGbS90cF-H~ccAdzhtj-rNk3Lb1U95EInFy3uWHjAgSHjCSrNfT9ksjHhx8L08IGuMh-GWrGK0WLFAVdvD7NEuagM9JE6L-fg__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \
	tar -xzvf cellranger-5.0.1.tar.gz && \
    rm -f cellranger-5.0.1.tar.gz
RUN cp /opt/cellranger-5.0.1/bin/sc_rna/* /usr/local/bin
RUN cp /opt/cellranger-5.0.1/bin/rna/* /usr/local/bin
RUN cp /opt/cellranger-5.0.1/bin/tenkit/* /usr/local/bin

ENV PATH="/opt/cellranger-5.0.1:${PATH}"
RUN echo "export PATH=/opt/cellranger-5.0.1:${PATH}" >> ~/.bashrc