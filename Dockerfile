# Our container needs just our binary
FROM alpine:3.20.3 as deploy

ARG MUSL_BIN

COPY "$MUSL_BIN" "/usr/local/bin/$MUSL_BIN"

RUN chmod +x "/usr/local/bin/$MUSL_BIN"

ENTRYPOINT ["$MUSL_BIN"]
