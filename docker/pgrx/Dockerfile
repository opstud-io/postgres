ARG RUST_TAG=1.85.0-bullseye

FROM rust:${RUST_TAG}

ARG PSQL_SUPPORT_VERSION
ARG PGRX_VERSION=0.11.4

ENV PSQL_VERSION=${PSQL_SUPPORT_VERSION:-15}

LABEL maintainer="Walter Franchetti <w@lter.it>"

RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/pgdg.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list


RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libxml2-utils \
    xsltproc \
    ccache \
    pkg-config \
    libclang-dev \
    clang \
    sudo \
    llvm-11-dev \
    libomp-11-dev \
    libfl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 pgrx && \
    useradd -m -u 1000 -g pgrx -s /bin/bash pgrx

RUN echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /home/pgrx/.bashrc

RUN echo 'export PATH="/home/pgrx/.cargo/bin:$PATH"' >> /etc/profile

RUN mkdir -p /home/pgrx/.cargo && \
    chown -R pgrx:pgrx /home/pgrx/.cargo

COPY package.sh /usr/bin/pgrx-package

RUN chown pgrx:pgrx /usr/bin/pgrx-package && chmod +x /usr/bin/pgrx-package

USER pgrx

ENV USER=pgrx

RUN cargo install cargo-pgrx --version ${PGRX_VERSION} --locked

RUN cargo pgrx init

WORKDIR /usr/src/app

# Mounting the plugin source code directory
VOLUME [ "/usr/src/app" ]

CMD [ "/usr/bin/pgrx-package" ]