# go-web-server-sample

## Getting started

### Install requirements

- [direnv](https://direnv.net/)

```sh
$ brew install jq yq
$ brew install --cask multipass
```

ref:

- [How to install Multipass on macOS \_ Multipass documentation](https://multipass.run/docs/installing-on-macos#heading--use-brew)

### Setup

#### Create `.envrc`

- Apple Silicon

```sh
export ARCH=arm64
```

- Intel

```sh
export ARCH=amd64
```

### Start development on local

```sh
$ make launch-vm # 1st time only
$ make start-vm # after the 2nd time
$ make docker-compose-up
```

### End development on local

```sh
$ make stop-vm
$ make docker-compose-down
```
