# Stage 1: grab Docker CLI (and compose plugin) from official image
FROM docker:26-cli AS dockercli

# Stage 2: Jenkins LTS with JDK17 + Docker CLI
FROM jenkins/jenkins:lts-jdk17

USER root

# Copy docker client and compose plugin into Jenkins image
COPY --from=dockercli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=dockercli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins

# Optional: tools you often need in pipelines
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# Ensure certs dir exists and is readable by jenkins
RUN mkdir -p /certs/client && chown -R jenkins:jenkins /certs

USER jenkins
