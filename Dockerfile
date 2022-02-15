ARG BASE
FROM openeuler/openeuler:${BASE}

ARG BASE
# # Fix openEuler 21.09 default image update issue
# RUN if [ "21.09" = "$BASE" ]; then \
#         sed -i 's#/EPOL#/EPOL/main#g' /etc/yum.repos.d/openEuler.repo; \
#     fi

RUN yum update -y && yum install wget ca-certificates -y

ARG VERSION
RUN if [ "x86_64" = "`arch`" ]; then \
        wget https://github.com/coredns/coredns/releases/download/v${VERSION}/coredns_${VERSION}_linux_amd64.tgz; \
    else \
        if [ "aarch64" = "`arch`" ]; then \
            wget https://github.com/coredns/coredns/releases/download/v${VERSION}/coredns_${VERSION}_linux_arm64.tgz; \
        else \
            echo "Unsupported architecture: `arch`"; \
            exit 1; \
        fi; \
    fi

RUN tar -xvzf coredns_${VERSION}_linux_*.tgz;

FROM scratch

COPY --from=0 /etc/ssl/certs /etc/ssl/certs
COPY --from=0 /coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]