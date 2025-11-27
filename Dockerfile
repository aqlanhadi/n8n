FROM golang:1.24.0-alpine AS go-builder

# Install git
RUN apk add --no-cache git

# Clone and build
RUN git clone --depth=1 https://github.com/aqlanhadi/kwgn-cli && \
    cd kwgn-cli && \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /go/bin/kwgn-cli . && \
    # Remove source code and credentials after building to reduce layer size
    cd / && rm -rf /go/src/* /root/.cache/go-build

FROM n8nio/n8n

USER root

# Install dependencies
RUN apk add --no-cache qpdf poppler poppler-utils

# Copy kwgn binary
COPY --from=go-builder /go/bin/kwgn-cli /usr/local/bin/kwgn
RUN chmod +x /usr/local/bin/kwgn

# Switch back to the default n8n user
USER node

EXPOSE 5678
