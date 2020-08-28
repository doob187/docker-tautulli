FROM alpine:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG TAUTULLI_RELEASE

# Inform app this is a docker env
ENV TAUTULLI_DOCKER=True

RUN \
 echo "**** install build packages ****" && \
 echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
 apk --no-cache update -qq && apk --no-cache upgrade -qq && apk --no-cache fix -qq && \
 echo "**** install build packages ****" && \
 apk add --no-cache bash gcc musl-dev \
    python3 python3-dev py3-pip \
    libxslt-dev libxml2-dev curl

RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	make \
	python3 \
	py3-virtualenv \
        gcc \
        git \
        python3 \
        python3-dev \
        py3-pip \
        musl-dev
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	jq \
	py3-openssl \
	py3-setuptools \
	python3 \
	py3-virtualenv \
        gcc \
        git \
        python3 \
        python3-dev \
        py3-pip \
        musl-dev
RUN \
 echo "**** install pip packages ****" && \
 pip3 install --no-cache-dir -U \
	mock \
	plexapi \
	pycryptodomex
RUN \
  echo "**** Install s6-overlay ****" && \ 
  curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' > /etc/S6_RELEASE && \
  wget https://github.com/just-containers/s6-overlay/releases/download/`cat /etc/S6_RELEASE`/s6-overlay-amd64.tar.gz -O /tmp/s6-overlay-amd64.tar.gz && \
  tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
  rm /tmp/s6-overlay-amd64.tar.gz && \
  echo "**** Installed s6-overlay `cat /etc/S6_RELEASE` ****"
RUN  \
  echo "**** install app ****" && \
  mkdir -p /app/tautulli && \
  echo "**** install tautulli ****" && \
  git clone --depth 1 --single-branch --branch master  https://github.com/zSeriesGuy/Tautulli.git /app/tautulli

RUN \
 addgroup tautulli && \
 adduser --system --no-create-home tautulli --ingroup tautulli && \
 chown tautulli:tautulli -R /app/tautulli && \
 python3 -m venv /app/tautulli && \
 source /app/tautulli/bin/activate && \
 python3 -m pip install --upgrade pip setuptools pip-tools
RUN \
  echo "**** update pip ****" && \
  pip -q install --upgrade pip idna==2.8
RUN python3 -m pip -q install --ignore-installed --no-cache-dir -r /app/tautulli/requirements.txt

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
