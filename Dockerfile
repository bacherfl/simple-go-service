# Use an official Golang runtime as a parent image
FROM golang:1.21.1-alpine as builder

# Set the build argument for responseTime with a default value
ARG responseTime=0
ARG version="dev"

# Set the working directory inside the container
WORKDIR /workspace

# Copy the local package files to the container at /go/src/github.com/bacherfl/simple-go-service
COPY . .

# Fetch the dependencies
RUN go mod download

# Build the application
RUN go build -tags=alpine -ldflags="-X main.ResponseTimeSeconds=${responseTime} -X main.Version=${version}" -o bin/simple-go-service

FROM gcr.io/distroless/static-debian11:nonroot AS production

WORKDIR /
COPY --from=builder /workspace/bin/simple-go-service .
USER 65532:65532

# Expose the port on which the application will run
EXPOSE 8080

ENTRYPOINT ["/simple-go-service"]
