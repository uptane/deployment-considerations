FROM haskell:8

# forked from https://github.com/ntwrkguru/pandoc-docker/blob/master/Dockerfile
LABEL  maintainer="Jon Oster <jon.i.oster@gmail.com>"

# Install dependencies
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update -y \
    && apt-get install -yqq --no-install-recommends \
       texlive-full \
       texlive-xetex \
       texlive-latex-extra \
       texlive-fonts-extra \
       texlive-bibtex-extra \
       fontconfig \
       lmodern \
       libghc-text-icu-dev \
       zip \
       python3-pip \
    && apt-get clean

# Install cabal and then pandoc + citeproc
RUN cabal update && cabal install pandoc pandoc-citeproc --force-reinstalls

RUN pip3 install setuptools && pip3 install pandoc-include

WORKDIR /build

ENTRYPOINT ["pandoc"]
CMD ["--help"]