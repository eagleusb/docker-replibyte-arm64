# syntax=docker/dockerfile:latest
FROM --platform=${TARGETPLATFORM} rust:1.59-buster as build

# multi-arch
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
  TZ=Europe/Paris \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8

ENV CARGO_BUILD_JOBS=16
ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV CARGO_PROFILE_RELEASE_DEBUG=1
ENV CARGO_PROFILE_RELEASE_OPT_LEVEL=2

USER root

# create a new empty shell project
RUN cargo new --bin replibyte
WORKDIR /replibyte

RUN cargo new --lib replibyte
RUN cargo new --lib dump-parser
RUN cargo new --lib subset

# copy over your manifests
COPY ./replibyte/Cargo.lock ./Cargo.lock
COPY ./replibyte/Cargo.toml ./Cargo.toml

# dump-parser
COPY ./replibyte/dump-parser ./dump-parser

# subset
COPY ./replibyte/subset ./subset

# replibyte
COPY ./replibyte/replibyte/Cargo.toml ./replibyte/Cargo.toml
COPY ./replibyte/replibyte/Cargo.lock ./replibyte/Cargo.lock

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./replibyte/replibyte/src ./replibyte/src
COPY ./replibyte/dump-parser/src ./dump-parser/src
COPY ./replibyte/subset/src ./subset/src

# build for release
RUN rm ./target/release/deps/replibyte*
RUN cargo build --release

# our final base
FROM --platform=${TARGETPLATFORM} ubuntu:23.10

# multi-arch
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
  TZ=Europe/Paris \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8

ARG DESTINATION_CONNECTION_URI
ARG ENCRYPTION_SECRET
ARG S3_ACCESS_KEY_ID
ARG S3_BUCKET
ARG S3_REGION
ARG S3_SECRET_ACCESS_KEY
ARG SOURCE_CONNECTION_URI

ENV DESTINATION_CONNECTION_URI $DESTINATION_CONNECTION_URI
ENV ENCRYPTION_SECRET $ENCRYPTION_SECRET
ENV S3_ACCESS_KEY_ID $S3_ACCESS_KEY_ID
ENV S3_BUCKET $S3_BUCKET
ENV S3_REGION $S3_REGION
ENV S3_SECRET_ACCESS_KEY $S3_SECRET_ACCESS_KEY
ENV SOURCE_CONNECTION_URI $SOURCE_CONNECTION_URI

# used to configure Github Packages
LABEL org.opencontainers.image.source https://github.com/eagleusb/docker-replibyte-arm64

# Install Postgres and MySQL binaries
RUN apt update && \
    apt upgrade -qqy && \
    apt install -qqy \
        curl \
        default-mysql-client \
        postgresql-client && \
    apt clean

# Install MongoDB tools
RUN curl -fsSLO "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-arm64-100.8.0.deb" && \
    dpkg -i mongodb-database-tools-*.deb && \
    rm -f mongodb-database-tools-*.deb

RUN curl -fsSLO "http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb" && \
    dpkg -i libssl1*arm64.deb && \
    rm -f libssl1*arm64.deb

# copy the build artifact from the build stage
COPY --from=build --chmod=755 /replibyte/target/release/replibyte /usr/local/bin

COPY conf.yaml.dist /${HOME:-/root}/conf.yaml.dist

WORKDIR ${HOME:-/root}

HEALTHCHECK NONE
ENTRYPOINT []
