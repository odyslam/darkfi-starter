FROM rust:slim as builder
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y git make jq gcc pkg-config python3-pip libsqlite3-dev
RUN git clone https://github.com/darkrenaissance/darkfi && pip3 install cargo-zigbuild
WORKDIR ./darkfi
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ] ; then CARGO_BUILD_TARGET=x86_64-unknown-linux-musl ; \ 
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ] ; then CARGO_BUILD_TARGET=aarch64-unknown-linux-musl ; fi && \
    rustup default nightly && rustup target add "${CARGO_BUILD_TARGET}" && \
    cargo update && cargo +nightly zigbuild --target ${CARGO_BUILD_TARGET} --all-features --release --package taud  && \
    cp /darkfi/target/"${CARGO_BUILD_TARGET}"/release/taud /darkfi/taud


FROM alpine:latest as run
RUN apk update && apk add --no-cache bash vim
COPY --from=builder /darkfi/taud /usr/local/bin/taud
COPY taud_config.toml /root/.config/darkfi/taud_config.toml
COPY run.sh /usr/local/bin/run.sh 
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT /usr/local/bin/run.sh
