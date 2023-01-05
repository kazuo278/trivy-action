ARG INPUT_TRIVY_VERSION=0.35.0
FROM aquasec/trivy:${INPUT_TRIVY_VERSION}
COPY entrypoint.sh /
RUN apk --no-cache add bash curl npm
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]