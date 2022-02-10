FROM alpine:3.13 as builder

RUN set -eux \
	&& apk add --no-cache \
		bc \
		gcc \
		musl-dev \
		py3-pip \
		python3 \
		python3-dev

ARG VERSION
RUN set -eux \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile black[jupyter]; \
	else \
		pip3 install --no-cache-dir --no-compile "black[jupyter]>=${VERSION},<$(echo "${VERSION}+0.1" | bc)"; \
	fi \
	\
	&& black --version | grep -E 'black.+?version\s[0-9]+|^black,\s[0-9][0-9].[0-9].[0-9]+' \
	\
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.13 as production
ARG VERSION
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#LABEL "org.opencontainers.image.created"=""
#LABEL "org.opencontainers.image.version"=""
#LABEL "org.opencontainers.image.revision"=""
LABEL "maintainer"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.authors"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.vendor"="cytopia"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.url"="https://github.com/cytopia/docker-black"
LABEL "org.opencontainers.image.documentation"="https://github.com/cytopia/docker-black"
LABEL "org.opencontainers.image.source"="https://github.com/cytopia/docker-black"
LABEL "org.opencontainers.image.ref.name"="black ${VERSION}"
LABEL "org.opencontainers.image.title"="black ${VERSION}"
LABEL "org.opencontainers.image.description"="black ${VERSION}"

RUN set -eux \
	&& apk add --no-cache python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/black /usr/bin/black
WORKDIR /data
ENTRYPOINT ["black"]
