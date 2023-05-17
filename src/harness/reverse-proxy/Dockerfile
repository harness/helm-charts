FROM golang:1.16-alpine as builder

WORKDIR /app
COPY . .
RUN go mod init github.com/harness/helm-charts/tree/arcticwolf-sd/src/harness/reverse-proxy
RUN CGO_ENABLED=0 GOOS=linux go build -o reverse-proxy .

FROM alpine:latest
COPY --from=builder /app/reverse-proxy /app/reverse-proxy
EXPOSE 8080

CMD ["/app/reverse-proxy"]
