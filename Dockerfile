# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS build

WORKDIR /src

ARG TARGETOS=linux
ARG TARGETARCH=amd64

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/apc-p15-tool ./cmd/tool && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/apc-p15-install ./cmd/install_only

FROM scratch

ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="APC P15 Tool" \
      org.opencontainers.image.description="Create and install SSL certificates for APC Network Management Cards" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"

COPY --from=build /out/apc-p15-tool /usr/local/bin/apc-p15-tool
COPY --from=build /out/apc-p15-install /usr/local/bin/apc-p15-install

ENTRYPOINT ["/usr/local/bin/apc-p15-tool"]
