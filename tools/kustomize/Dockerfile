FROM gcr.io/google.com/cloudsdktool/cloud-sdk:327.0.0-alpine
ENV KUSTOMIZE_URL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v3.9.1/kustomize_v3.9.1_linux_amd64.tar.gz"
RUN apk add --no-cache curl && \
    curl -sSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl && \
    curl -sSL "${KUSTOMIZE_URL}" | tar xzf - --directory /usr/local/bin && chmod +x /usr/local/bin/kustomize
COPY entrypoint.sh /usr/local/bin/
RUN chown +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
