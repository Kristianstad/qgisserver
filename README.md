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
| `standard` | `latest`, `<qgis-version>`, `sha-<commit>` | A flattened image with updated Ubuntu packages, unused packages removed (see below), a worker default, and this project's license. |
| `slim` | `slim`, `<qgis-version>-slim`, `sha-<commit>-slim` | A flattened image without package documentation (copyright files are kept), Python test directories, build caches, or the LLVM 15 and Clang 15 libraries used by Qt's `qdoc`. |
| `ultra-slim` | `ultra-slim`, `<qgis-version>-ultra-slim`, `sha-<commit>-ultra-slim` | Also removes `scipy`, `sympy`, `matplotlib`, `plotly`, and QGIS cpt-city color ramps. Plugins requiring those Python modules and projects using those ramps are unsupported. |

Use a version-specific tag for deployments when you want to control QGIS upgrades. Images are published to `ghcr.io/kristianstad/qgisserver`.

All variants install the latest Ubuntu package updates at build time. QGIS packages are held at the version of the base image. Packages that QGIS Server does not use are removed: Git, Perl, `ping`, `unzip`, and the Ubuntu upgrade and Ubuntu Pro tools. The Microsoft core fonts stay installed, but their installer package is removed. These tools are no longer available inside the container. `wget` is retained for health checks.

All variants remove Unicode conformance test data while retaining Unicode character properties. The slim and ultra-slim variants also omit LLVM 15 and Clang 15, so `qdoc` and plugins requiring those libraries are unsupported. The slim build checks the `qdoc` library versions and fails if the base image changes them. These files belong to installed Ubuntu packages: package verification will report them missing, and package updates inside a container may restore them.

Flattening avoids retaining superseded files from base image layers, but the images no longer share layers with the upstream image. An update may therefore require downloading the whole image layer again. Additional upstream image labels are not inherited; project labels are retained. The runtime configuration is checked against the full image during CI builds.

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
Ubuntu package updates are cached in the build cache. Use `docker build --no-cache` to install the latest updates when rebuilding locally.

## License

Files in this repository are licensed under BSD 2-Clause; see [LICENSE](LICENSE). The image also includes QGIS, py-qgis-server, Ubuntu packages, and other software under their respective licenses. Package copyright notices are retained under `/usr/share/doc/<package>/copyright`.
