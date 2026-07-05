# syntax=docker/dockerfile:1
#
# golfTiles build image
# =====================
# Bundles everything run_all.sh needs to turn OpenStreetMap .pbf extracts into
# golfTiles.pmtiles, so you don't have to install any of it on the host:
#
#   * osmium-tool           - drives the sort / merge / tags-filter / extract steps
#   * tilemaker (v3.1.0)    - built from the pinned submodule, against Lua 5.4
#                             (the schema in custom-tilemaker/process.lua uses
#                             math.tointeger(), which requires Lua 5.3+; the
#                             lua5.4 Ubuntu package satisfies that, as of 2026-07-05)
#
# ---------------------------------------------------------------------------
# Build (run from the repo root; make sure the submodule source is present):
#
#   git submodule update --init
#   docker build -t golftiles .
#
# Run (mount the repo so your data/*.pbf are read and the resulting
# golfTiles.pmtiles is written back onto the host):
#
#   docker run --rm -v "$PWD:/app" golftiles
#
# Put your .pbf extract(s) in ./data/ first. The output lands at
# ./golfTiles.pmtiles. Inspect it at https://pmtiles.io/ .
# ---------------------------------------------------------------------------

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# osmium-tool plus tilemaker's build + runtime dependencies.
# The dependency list mirrors tilemaker/docs/INSTALL.md (Ubuntu).
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        osmium-tool \
        build-essential \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-iostreams-dev \
        lua5.4 \
        liblua5.4-dev \
        libshp-dev \
        libsqlite3-dev \
        rapidjson-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Build tilemaker from the vendored submodule and install the binary onto PATH
# (/usr/local/bin/tilemaker). Kept as a separate layer so it is cached
# independently of changes to the schema / scripts below.
#
# JOBS caps compile parallelism. tilemaker's Boost.Geometry translation units
# each need ~1.5-2 GB of RAM, so an unbounded -j$(nproc) OOM-kills the compiler
# on a memory-limited Docker VM. Default 2 fits comfortably in ~5 GB; raise it
# with --build-arg JOBS=N if the VM has more headroom, drop to 1 if it OOMs.
ARG JOBS=2
COPY tilemaker/ /src/tilemaker/
RUN make -C /src/tilemaker -j"${JOBS}" \
    && make -C /src/tilemaker install \
    && rm -rf /src/tilemaker

WORKDIR /app

# Only the pieces run_all.sh actually needs. The repo is expected to be
# bind-mounted over /app at run time (see header), so these are a fallback that
# lets the image also run stand-alone.
COPY run_all.sh ./run_all.sh
COPY custom-tilemaker/ ./custom-tilemaker/
RUN chmod +x run_all.sh \
    && mkdir -p data/processed store

# run_all.sh reads data/*.pbf and writes golfTiles.pmtiles into the workdir.
ENTRYPOINT ["./run_all.sh"]
