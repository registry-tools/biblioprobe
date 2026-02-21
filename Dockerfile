FROM ruby:3.4.3-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts to /app

WORKDIR /usr/src/app

COPY . .

# Make probe.rb executable
RUN chmod +x /usr/src/app/bin/probe.rb

RUN bundle config set --global deployment true
RUN bundle install

# Clean up build dependencies
FROM ruby:3.4.3-slim
COPY --from=build /usr/src/app /usr/src/app
RUN bundle config set --global deployment true

WORKDIR /usr/src/app

RUN bundle install

# Set entrypoint
ENTRYPOINT ["/usr/src/app/bin/probe.rb", "--output", "/data/biblioprobe.json", "/data"]
