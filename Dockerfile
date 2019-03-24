
FROM golang:1.11-alpine AS build

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

# List project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
COPY Gopkg.lock Gopkg.toml /go/src/cosmos/
WORKDIR /go/src/cosmos/
# Install library dependencies
RUN dep ensure -vendor-only

# Copy the entire project and build it
# This layer is rebuilt when a file changes in the project directory
COPY . /go/src/cosmos/
RUN go build -o /bin/cosmos

# This results in a single layer image
FROM scratch
COPY --from=build /bin/cosmos /bin/cosmos
ENTRYPOINT ["/bin/cosmos"]
CMD ["--help"]


