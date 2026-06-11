FROM golang:1.23-alpine3.20 AS build

WORKDIR /src

COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/server .

FROM scratch

COPY --from=build /out/server /server

USER 65532:65532

EXPOSE 3000

CMD ["/server"]
