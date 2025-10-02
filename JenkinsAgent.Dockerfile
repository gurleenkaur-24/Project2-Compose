# Stage just to copy the Docker CLI
FROM docker:26-cli AS dockercli

# Actual build agent: Node 16
FROM node:16-alpine

# Useful tools
RUN apk add --no-cache git bash

# Add Docker CLI + compose plugin so the agent can talk to DinD
COPY --from=dockercli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=dockercli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins
