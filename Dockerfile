FROM node:current-alpine as nodebuild
WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY templates ./templates
RUN pnpm run css:build

FROM golang:alpine as gobuild
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY --from=nodebuild /app/static ./static
COPY . .
RUN go build -o unibocalendar

FROM alpine
COPY --from=gobuild /app/unibocalendar .

ENV PORT=8080
EXPOSE 8080

ENV GIN_MODE=release

CMD ["./unibocalendar"]




