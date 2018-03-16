FROM golang:1.10

ENV GOOS="linux"
ENV GOARCH="amd64"
ENV CGO_ENABLED=0

WORKDIR $GOPATH/src/github.com/cosmopetrich/twitter_stream_exporter
ADD .git .git
RUN git checkout .

RUN export VERSION=$(git describe --tags --dirty) SHA1=$(git rev-parse --short --verify HEAD) BUILD_DATE=$(date -u +%F-%T) && env && go build -a -tags netgo -ldflags "-extldflags -static -X main.Version=${VERSION} -X main.CommitSHA1=${SHA1} -X main.BuildDate=${BUILD_DATE}"

FROM alpine:3.7

EXPOSE 19000

RUN apk add --no-cache ca-certificates

COPY --from=0 /go/src/github.com/cosmopetrich/twitter_stream_exporter /usr/bin/

USER nobody

ENTRYPOINT ["/usr/bin/twitter_stream_exporter"]
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/simonswine/twitter_stream_exporter" \
      org.label-schema.license="MIT"
