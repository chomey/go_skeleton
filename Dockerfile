FROM golang:alpine

MAINTAINER Chomey <chomeycoding@gmail.com>

RUN apk add --update ca-certificates \
    && rm -rf /var/cache/apk/*

ADD bin/go_skeleton_linux_amd64 /app/service
ADD service /app/

WORKDIR /app

ENTRYPOINT ["/app/service"]

EXPOSE 9090