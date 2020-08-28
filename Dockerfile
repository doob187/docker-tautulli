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
 apk add --quiet --no-cache \
	jq \
	py3-openssl \
	py3-setuptools \
	curl \
	g++ \
	gcc \
	make \
	py3-pip \
	python3-venv \ 
	python3-all-dev \
	git-core
RUN \
 echo "**** install pip packages ****" && \
 pip3 install --no-cache-dir -U \
	mock \
	plexapi \
	pycryptodomex
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
 pip3 install -r /app/tautulli/requirements.txt && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
