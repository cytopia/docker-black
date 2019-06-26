FROM alpine:3.9 as builder

RUN set -x \
	&& apk add --no-cache \
		bc \
		python3

ARG VERSION=latest
RUN set -x \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile black; \
	else \
		pip3 install --no-cache-dir --no-compile "black>=${VERSION},<$(echo "${VERSION}+0.1" | bc)"; \
	fi \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.9 as production
LABEL \
	maintainer="cytopia <cytopia@everythingcli.org>" \
	repo="https://github.com/cytopia/docker-black"
RUN set -x \
	&& apk add --no-cache python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf
COPY --from=builder /usr/lib/python3.6/site-packages/ /usr/lib/python3.6/site-packages/
COPY --from=builder /usr/bin/black /usr/bin/black
WORKDIR /data
ENTRYPOINT ["black"]
