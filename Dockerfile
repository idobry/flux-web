#
# Stage 1
#
FROM library/golang as builder

ENV APP_DIR $GOPATH/src/flux-web
RUN mkdir -p $APP_DIR

WORKDIR $GOPATH/src/flux-web

ADD go.mod .
ADD go.sum .

RUN go mod download

ADD . $APP_DIR

RUN GO111MODULE=on CGO_ENABLED=0 go build -ldflags '-w -s' -o /flux-web && \
    cp -r views/ /views && \
    cp -r static/ /static  && \
    cp -r conf/ /conf
#
# Stage 2
#
FROM alpine:3.8
RUN adduser -D -u 1000 flux-web
COPY --from=builder /flux-web /flux-web
COPY --from=builder /views /views
COPY --from=builder /static /static
COPY --from=builder /conf /conf
USER 1000
ENTRYPOINT ["/flux-web"]
