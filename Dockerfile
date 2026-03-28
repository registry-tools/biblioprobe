ARG RUBY_VERSION=4.0.2
FROM ruby:$RUBY_VERSION-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts to /app

WORKDIR /usr/src/app

COPY . .

RUN bundle config set --global deployment true
RUN bundle install

# Install osv-scanner
FROM golang:tip-alpine AS osv-scanner
RUN go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest

# Clean up build dependencies
FROM ruby:$RUBY_VERSION-slim

COPY --from=build /usr/src/app /usr/src/app
COPY --from=osv-scanner /go/bin/osv-scanner /usr/bin/osv-scanner

RUN bundle config set --global deployment true

WORKDIR /usr/src/app

RUN bundle install
# Make scripts executable
RUN chmod +x /usr/src/app/bin/probe.rb

# Set entrypoint
ENTRYPOINT ["/usr/src/app/bin/probe.rb", "/data"]
