FROM gcr.io/google.com/cloudsdktool/cloud-sdk:327.0.0-alpine
RUN apk add --no-cache bash curl && \
    curl -sSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl && \
    curl -s https://toolkit.fluxcd.io/install.sh | bash
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
