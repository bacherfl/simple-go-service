# Use an official Golang runtime as a parent image
FROM golang:1.21.1-alpine

# Set the build argument for responseTime with a default value
ARG responseTime=0
ARG version="dev"

# Set the working directory inside the container
WORKDIR /go/src/github.com/bacherfl/simple-go-service

# Copy the local package files to the container at /go/src/github.com/bacherfl/simple-go-service
COPY . .
COPY .git /.git

# Fetch the dependencies
RUN go mod download

# Build the application
RUN go build -gcflags="all=-dwarflocationlists=true" -ldflags="-X main.ResponseTimeSeconds=${responseTime} -X main.Version=${version}" -o simple-go-service

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["./simple-go-service"]
