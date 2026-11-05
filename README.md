# QGIS Server images

Docker images for [QGIS Server](https://github.com/3liz/py-qgis-server), based on `3liz/qgis-map-server`. This project does not include Varnish or another reverse proxy. QGIS Server receives requests directly on port 8080.

## Run

Put QGIS projects and their data files in a local directory, then run:

```bash
docker run -d --name qgisserver -p 8080:8080 \
  -v "$PWD/projects:/qgis-data" \
  ghcr.io/kristianstad/qgisserver:latest
```

The projects must be readable by the QGIS Server process (UID 9001). Do not set `--user`; the base image configures the server process itself.

Check the service at `http://localhost:8080/ping`. A WMS GetCapabilities request for `projects/map.qgs` is:

```text
http://localhost:8080/ows/?MAP=map.qgs&SERVICE=WMS&REQUEST=GetCapabilities
```

QGIS Server settings use the `QGSRV_...` environment variables documented by [py-qgis-server](https://docs.3liz.org/py-qgis-server/). The default worker count is 2; set `QGSRV_SERVER_WORKERS` to match the CPU capacity allocated to the container.

## Image variants

GitHub Actions builds all three variants from the same commit using Dockerfile targets:

| Target | Tags | Contents |
|---|---|---|
| `main` | `latest`, `<qgis-version>`, `sha-<commit>` | Upstream QGIS Server base image with a worker default and this project's license. |
| `slim` | `slim`, `<qgis-version>-slim`, `sha-<commit>-slim` | A flattened image without package documentation (copyright files are kept), Python test directories, or build caches. |
| `ultra-slim` | `ultra-slim`, `<qgis-version>-ultra-slim`, `sha-<commit>-ultra-slim` | Also removes `scipy`, `sympy`, `matplotlib`, `plotly`, and QGIS cpt-city color ramps. Plugins requiring those Python modules and projects using those ramps are unsupported. |

Use a version-specific tag for deployments when you want to control QGIS upgrades. Images are published to `ghcr.io/kristianstad/qgisserver`.

## Configuration and logs

Set QGIS Server options with `-e`, for example `-e QGSRV_SERVER_WORKERS=4`. Logs are written to the container output:

```bash
docker logs qgisserver
```

On Windows without Docker Desktop, WSL 2.9.3 or later can run Linux containers with `wslc`:

```powershell
wslc run -d --rm --name qgisserver -p 8080:8080 -v "C:\qgis-projects:/qgis-data" ghcr.io/kristianstad/qgisserver:latest
```

## Build locally

```bash
docker build -t qgisserver .
docker run --rm -p 8080:8080 -v "$PWD/projects:/qgis-data" qgisserver
```

The source image is amd64. Other architectures may require emulation.

## License

Files in this repository are licensed under BSD 2-Clause; see [LICENSE](LICENSE). The image also includes QGIS, py-qgis-server, Ubuntu packages, and other software under their respective licenses. Package copyright notices are retained under `/usr/share/doc/<package>/copyright`.
