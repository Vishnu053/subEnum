FROM golang:alpine

LABEL maintainer="vmk053"

RUN apk add git
RUN apk add bash

RUN git clone https://github.com/Vishnu053/subEnum

RUN mkdir /data

CMD "/bin/bash"
