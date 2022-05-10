# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/go
ARG VARIANT=1-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/go:${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        gpg \
        inotify-tools

USER vscode

COPY scripts/copy-kube-config.sh /usr/local/share/
RUN echo "source /usr/local/share/copy-kube-config.sh" | tee -a ~/.bashrc >> ~/.zshrc

# Install Kubebuilder
RUN    export BUILDARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
    && export OS=$(uname | awk '{print tolower($0)}') \
    && export VERSION=3.3.0 \
    && curl -L -O "https://github.com/kubernetes-sigs/kubebuilder/releases/download/v${VERSION}/kubebuilder_${OS}_${BUILDARCH}" \
    && sudo mv kubebuilder_${OS}_${BUILDARCH} /usr/local/bin/kubebuilder \
    && chmod +x /usr/local/bin/kubebuilder

RUN    export BUILDARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
    && export K8S_VERSION=1.23.3 \
    && curl -sSLo envtest-bins.tar.gz "https://go.kubebuilder.io/test-tools/${K8S_VERSION}/$(go env GOOS)/$(go env GOARCH)" \
    && sudo mkdir -m 777 /usr/local/kubebuilder \
    && tar -C /usr/local/kubebuilder --strip-components=1 -zvxf envtest-bins.tar.gz

# Install operator-sdk
RUN    export BUILDARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
    && export OS=$(uname | awk '{print tolower($0)}') \
    && export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.18.1 \
    && curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${BUILDARCH} \
    && echo ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${BUILDARCH} \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E \
    && curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt \
    && curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc \
    && gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc \
    && grep operator-sdk_${OS}_${BUILDARCH} checksums.txt | sha256sum -c - \
    && chmod +x operator-sdk_${OS}_${BUILDARCH} \
    && sudo mv operator-sdk_${OS}_${BUILDARCH} /usr/local/bin/operator-sdk
