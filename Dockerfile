# Start from r-ver, which natively supports both linux/amd64 and linux/arm64
FROM rocker/r-ver:4.5.0

ARG TARGETARCH

# ---- System dependencies -----------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-venv python3-pip \
    curl ca-certificates \
    libxml2-dev libssl-dev libcurl4-openssl-dev libfontconfig1-dev \
    libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev \
    libtiff5-dev libjpeg-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- R packages (global) -----------------------------------------------------
RUN install2.r --error --skipinstalled tidyverse renv

# ---- Quarto ------------------------------------------------------------------
RUN QUARTO_VERSION="1.9.0" && \
    if [ "$TARGETARCH" = "arm64" ]; then QUARTO_ARCH="linux-arm64"; else QUARTO_ARCH="linux-amd64"; fi && \
    curl -LO "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-${QUARTO_ARCH}.deb" && \
    dpkg -i "quarto-${QUARTO_VERSION}-${QUARTO_ARCH}.deb" && \
    rm "quarto-${QUARTO_VERSION}-${QUARTO_ARCH}.deb"

# ---- Julia -------------------------------------------------------------------
RUN JULIA_VERSION="1.12.0" && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        JULIA_ARCH="aarch64"; JULIA_DIR="aarch64"; \
    else \
        JULIA_ARCH="x86_64"; JULIA_DIR="x64"; \
    fi && \
    curl -L "https://julialang-s3.julialang.org/bin/linux/${JULIA_DIR}/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-${JULIA_ARCH}.tar.gz" | tar -xz -C /opt/ && \
    ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia

# ---- uv (Python environment manager) ----------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# ---- Bake Julia project deps into the default depot -------------------------
# Packages land in /root/.julia and are found at runtime via `julia --project=.`
COPY Project.toml Manifest.toml /tmp/julia-deps/
RUN cd /tmp/julia-deps \
    && julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()' \
    && rm -rf /tmp/julia-deps

# IJulia for Quarto notebook support
RUN julia -e 'using Pkg; Pkg.add("IJulia")'

# ---- Bake Python deps (snakemake + project) into a persistent venv ----------
COPY pyproject.toml /tmp/py-deps/
RUN cd /tmp/py-deps \
    && uv venv /opt/venv \
    && VIRTUAL_ENV=/opt/venv uv pip install snakemake pyyaml \
    && rm -rf /tmp/py-deps
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /workspace
