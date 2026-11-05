# syntax=docker/dockerfile:1
# =============================================================================
# QGIS Server base image with a default worker count.
# =============================================================================
ARG QGIS_SERVER_VERSION=3.44.15
FROM 3liz/qgis-map-server:${QGIS_SERVER_VERSION} AS full

LABEL org.opencontainers.image.title="QGIS Server" \
      org.opencontainers.image.description="QGIS Server based on 3liz/qgis-map-server" \
      org.opencontainers.image.base.name="docker.io/3liz/qgis-map-server"

ENV QGSRV_SERVER_WORKERS=2

COPY LICENSE /usr/share/doc/qgisserver/LICENSE

EXPOSE 8080

FROM full AS slim-root
RUN find /usr/share/doc ! -xtype d ! -name copyright ! -path /usr/share/doc/qgisserver/LICENSE -delete \
      && find /usr/share/doc -xdev -type d -empty -delete \
      && find /usr/lib/python3/dist-packages /opt/local -type d \( -name tests -o -name test \) -prune -exec rm -rf {} + \
      && rm -rf /root/.cache /var/cache/debconf/* /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/*

FROM scratch AS slim
COPY --from=slim-root / /
LABEL org.opencontainers.image.title="QGIS Server slim" \
        org.opencontainers.image.description="Flattened QGIS Server image based on 3liz/qgis-map-server" \
        org.opencontainers.image.base.name="docker.io/3liz/qgis-map-server"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
      LC_ALL=C.UTF-8 \
      QGIS_DISABLE_MESSAGE_HOOKS=1 \
      QGIS_NO_OVERRIDE_IMPORT=1 \
      QGSRV_DATA_PATH=/usr/local/share/qgis-server \
      QGSRV_SERVER_WORKERS=2
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["qgisserver"]

FROM slim-root AS ultra-root
RUN cd /usr/lib/python3/dist-packages \
      && rm -rf plotly plotly-* _plotly_future_ _plotly_utils scipy scipy-* sympy sympy-* isympy.py \
                    mpmath mpmath-* matplotlib matplotlib-* mpl_toolkits \
      && rm -rf /etc/matplotlibrc /usr/share/matplotlib /usr/share/python3-plotly /usr/share/menu/python3-sympy \
                    /usr/share/qgis/resources/cpt-city-qgis-min

FROM scratch AS ultra-slim
COPY --from=ultra-root / /
LABEL org.opencontainers.image.title="QGIS Server ultra-slim" \
        org.opencontainers.image.description="Ultra-slim QGIS Server image based on 3liz/qgis-map-server" \
        org.opencontainers.image.base.name="docker.io/3liz/qgis-map-server"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
      LC_ALL=C.UTF-8 \
      QGIS_DISABLE_MESSAGE_HOOKS=1 \
      QGIS_NO_OVERRIDE_IMPORT=1 \
      QGSRV_DATA_PATH=/usr/local/share/qgis-server \
      QGSRV_SERVER_WORKERS=2
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["qgisserver"]

FROM full AS standard
