FROM crystallang/crystal:0.31.1

WORKDIR /app

# Add
# - ping (not in base xenial image the crystal image is based off)
RUN apt-get update && \
    apt-get install --no-install-recommends -y iputils-ping=3:20121221-5ubuntu2 curl && \
    rm -rf /var/lib/apt/lists/*

# Install shards for caching
COPY shard.yml shard.yml
RUN shards install --production

# Add src
COPY ./src /app/src

# Build application
RUN crystal build /app/src/rubber-soul.cr --release --no-debug --error-trace

# Run the app binding on port 3000
EXPOSE 3000
HEALTHCHECK CMD curl -I localhost:3000/healthz
CMD ["/app/rubber-soul", "-b", "0.0.0.0", "-p", "3000"]
