FROM rust:slim as builder

# RUN apt-get update && apt-get install -y git make jq gcc pkg-config libmpg123-dev && rustup target add wasm32-unknown-unknown
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/odyslam/darkfi
ARG CARGO_BUILD_TARGET=x86_64-unknown-linux-musl
RUN apt-get update && apt-get install -y git make jq gcc pkg-config python3-pip
RUN pip3 install cargo-zigbuild
RUN rustup target add "${CARGO_BUILD_TARGET}"
# ARG CARGO_BUILD_TARGET=aarch64-unknown-linux-musl
WORKDIR ./darkfi
RUN cargo zigbuild --target x86_64-unknown-linux-musl --all-features --release --package ircd
RUN cp /darkfi/target/"${CARGO_BUILD_TARGET}"/release/ircd /darkfi/ircd


FROM rust:alpine as run
RUN apk update && apk add --no-cache bash vi
COPY --from=builder /darkfi/ircd /usr/local/bin/ircd
COPY ircd_config.toml /root/.config/darkfi/ircd_config.toml
COPY run.sh /usr/local/bin/run.sh 
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT /usr/local/bin/run.sh
