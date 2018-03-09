FROM golang:1.9-alpine
RUN apk add --no-cache git gcc musl-dev
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/multirootca
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssljson

FROM alpine:latest
RUN apk -v --update --no-cache add \
    python \
    py-pip \
    jq \
    curl \
    ca-certificates \
    bash \
  && \
  pip install --upgrade awscli && \
  apk -v --purge del py-pip
COPY --from=0 /go/bin/ /bin/
COPY bin/ /bin/


COPY ca /ca
COPY csr /csr

CMD [ "/bin/runca" ]
