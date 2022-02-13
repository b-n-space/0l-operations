# 0l-Operations

Tooling for operations of https://0l.network

## Requirements

- Docker 19+
- [Task](https://taskfile.dev/#/installation)
- Internet connection
- Dedicated IP with opened ports (check each service)

## How to

- Clone this repo
- Create `.env` file (`cp example.env .env`) and set relevant variables
  - `OL_BRANCH`: [Libra](https://github.com/OLSF/libra/)'s release tag or branch to check out and build
  - `OL_IMAGE`: Docker image (`username/image:tag`), used to build/push images, also to run services

- Build and push docker images
  ```shell
  task docker:build
  task docker:push
  ```

- Use docker-compose to manage services
  This requires setting
  - `OL_DATA_DIR`: points to host path where 0L data directory is located
  - `OL_NODE_MODE`: determines node mode `fullnode`, `validator`, `vfn`
  
  ```shell
  # Start a shell service with all 0L binaries available
  # Useful to run `txs` commands
  docker-compose run --rm shell
  
  # Start service(s)
  docker-compose up tower 

  # You can pass one or more services
  docker-compose up tower monitor node

  # Start service(s) in background
  docker-compose up -d tower monitor node 

  # Display all logs
  docker-compose logs tower

  # Tail logs
  docker-compose logs -f --tail 50 node
  
  # Force recreate and start service(s)
  docker-compose up -d --force-recreate node 
  
  # Stop service(s)
  docker-compose stop node

  # Stops containers and removes containers, networks, volumes, and images
  docker-compose down
  ```

## `node` service

> Ports - operations: 6179, 6180, 8080

> Ports - monitoring: 9101, 9102

This service can run as either of: `fullnode`, `validator`, `vfn`. That is determined by the `OL_NODE_MODE` env
variable.

## `tower` service

Tower service can be launched in multiple modes. That depends on whether the accompanying node is fully synced or not.
Validators have operator accounts that can be used to start tower without providing mnemonic phrase for owner account.

- mode 1: initial start uses upstream as fullnode/validator are not yet synced
  > `entrypoint: [ "tower", "--use-upstream-url", "--verbose", "start" ]`
- mode 2: fullnode/validator are synced: run as non-operator (requires MNEM)
  > `entrypoint: [ "tower", "--verbose", "start" ]`
- mode 3: fullnode/validator are synced: run as operator
  > `entrypoint: [ "tower", "--is-operator", "--verbose", "start" ]`

## `monitor` service

> Port: 3030

Start web monitor.

## `shell` service

Run different ol and other commands inside an isolated container.

---

> Old readme

# 0L Docker

This is an updated collection of Docker and Docker-Compose files that make use of the latest 0L binaries and guides.

> This is a work in progress, and the role of this file is to help to navigate the development.
> nourspace

## Goals

- Easily create account and get onboarded
- Easily run tower, full-node, and validator on a VPS that has Docker installed
- Ability to use custom upstream ips, data directory, etc
- Logging visibility

## Requirements

- VPS with Docker 19+ installed
- [Task](https://taskfile.dev/#/installation)
- Internet connection
- Dedicated IP with opened ports

## How to

### Build and run base image

```bash
# While in ./docker/0L
task docker:build

# Shell
task docker:shell
```

### Use Docker-Compose

WIP

## Todos

### Questions

- [x] Easy or Hard?
  > Hard as we need to build binaries, `ol start` requires proper onboarding which won't be the case
- [x] Build from source or binaries?

### Docker

- [x] Find good base image: `ubuntu:20.04`
- [x] Use easy mode instructions wherever possible?
  - ~~Using binaries for now~~
  - Moved to hard mode
- [ ] Allow passing configs: data directory, config, and other flags
  ~~I used an ugly way of creating alias scripts~~
  - Docker-Compose will allow mounting data paths easily so `--config` might not be needed
- [ ] Open and bind correct ports
- [ ] Security
  - [ ] use non-root user
  - [ ] what else?

### Compose

- [ ] Create docker-compose files to facilitate different scenarios
  - [ ] utils: onboarding
  - [ ] fullnode: running a fullnode
  - [ ] tower: running a miner
  - [ ] validator: running a validator

### Deployment

- Create a temporary image and host it on own Dockerhub
- Update CI to build image

### Cleanups

- [ ] Squash and remove unnecessary commits
- [ ] Optimise RUN commands and follow Docker best practices
- [ ] Update this README
