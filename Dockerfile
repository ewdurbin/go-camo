# syntax=docker/dockerfile:1

FROM golang:1.16-alpine AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY Makefile /app/Makefile
COPY cmd /app/cmd
COPY pkg /app/pkg
COPY .git /app/.git

RUN apk add --update make git
RUN make build

FROM alpine:latest as certs
RUN apk --update add ca-certificates

FROM scratch
ENV PATH=/bin
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /app/build/bin/go-camo /bin/go-camo
