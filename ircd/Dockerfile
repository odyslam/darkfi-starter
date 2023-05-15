FROM rust:slim as builder

# RUN apt-get update && apt-get install -y git make jq gcc pkg-config libmpg123-dev && rustup target add wasm32-unknown-unknown
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/odyslam/darkfi
# ARG CARGO_BUILD_TARGET=x86_64-unknown-linux-musl
RUN apt-get update && apt-get install -y git make jq gcc pkg-config python3-pip
RUN pip3 install cargo-zigbuild
ARG TARGETPLATFORM
WORKDIR ./darkfi
RUN echo "TARGETPLATFORM=${TARGETPLATFORM}"
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ] ; then CARGO_BUILD_TARGET=x86_64-unknown-linux-musl ; \ 
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ] ; then CARGO_BUILD_TARGET=aarch64-unknown-linux-musl ; fi && \
    rustup target add "${CARGO_BUILD_TARGET}" && \
    cargo zigbuild --target ${CARGO_BUILD_TARGET} --all-features --release --package ircd  && \
    cp /darkfi/target/"${CARGO_BUILD_TARGET}"/release/ircd /darkfi/ircd


FROM rust:alpine as run
RUN apk update && apk add --no-cache bash vim
COPY --from=builder /darkfi/ircd /usr/local/bin/ircd
COPY ircd_config.toml /root/.config/darkfi/ircd_config.toml
COPY run.sh /usr/local/bin/run.sh 
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT /usr/local/bin/run.sh
