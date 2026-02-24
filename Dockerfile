FROM ruby:3.4.3-slim AS build

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
FROM golang:1.25-alpine AS osv-scanner
RUN go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest

# Clean up build dependencies
FROM ruby:3.4.3-slim

COPY --from=build /usr/src/app /usr/src/app
COPY --from=osv-scanner /go/bin/osv-scanner /usr/bin/osv-scanner

RUN bundle config set --global deployment true

WORKDIR /usr/src/app

RUN bundle install

# Make scripts executable
RUN chmod +x /usr/src/app/bin/probe.rb
RUN chmod +x /usr/src/app/scan.sh

# Set entrypoint
ENTRYPOINT ["/usr/src/app/scan.sh"]
