# syntax=docker/dockerfile:1
# =============================================================================
# QGIS Server base image with a default worker count.
# =============================================================================
ARG QGIS_SERVER_VERSION=3.44.15
FROM 3liz/qgis-map-server:${QGIS_SERVER_VERSION}

LABEL org.opencontainers.image.title="QGIS Server" \
      org.opencontainers.image.description="QGIS Server based on 3liz/qgis-map-server" \
      org.opencontainers.image.base.name="docker.io/3liz/qgis-map-server"

ENV QGSRV_SERVER_WORKERS=2

COPY LICENSE /usr/share/doc/qgisserver/LICENSE

EXPOSE 8080
