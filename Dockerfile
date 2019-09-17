FROM lachlanevenson/k8s-kubectl:v1.15.3

RUN apk --no-cache add bash py-pip python curl && \
    pip install --upgrade pip awscli==1.16.239

COPY run.sh /run.sh

# overwrite base image kubectl entrypoint
ENTRYPOINT ["/run.sh"]

CMD ["/run.sh"]
