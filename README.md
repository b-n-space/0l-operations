# 0l-Operations

Tooling for operations of https://0l.network

## Requirements

- Docker 19+
- [Task](https://taskfile.dev/#/installation)
- Internet connection
- Dedicated IP with opened ports (check each service)

## How to

- Clone this repo
- Create `.env` file (`cp example.env .env`) and set relevant variables. This depends on what you want to do:
  - Manage Docker images
  - Operate a fullnode or a validator setup
  - Run a miner only

### Manage docker images

> There exists a list of pre-built images that you may directly use here: https://hub.docker.com/r/nourspace/0l/tags
> These images were built using the [Dockerfile](./Dockerfile) in this repo and come without any guaranties.

- Set these env variables
  - `OL_BRANCH`: [Libra](https://github.com/OLSF/libra/)'s release tag or branch to check out and build
  - `OL_IMAGE`: Docker image (`username/image:tag`), used to build/push images, also to run services

- Build and push docker images
  ```shell
  task docker:build
  task docker:push
  ```

### Operate 0L node (Fullnode or Validator/VFN)

- Set these env variables
  - `OL_DATA_DIR`: points to host path where 0L data directory is located
  > Create this directory if it does not yet exist
  - `OL_NODE_MODE`: determines node mode `fullnode`, `validator`, `vfn`

- Use docker-compose to manage services: `node`, `tower`, `monitor`

  ```shell
  # Start service(s) in background
  docker-compose up -d node tower monitor 

  # Tail logs
  docker-compose logs -f --tail 50
  ```

### Run a Tower (0L Miner) only

> This is useful if you have a unix server, and you only want to mine 0L coins and identity without operating any nodes.

- Set these env variables
  - `OL_DATA_DIR`: points to host path where 0L data directory is located
  > Create this directory if it does not yet exist
  - `OL_TOWER_OPERATOR=''`: this is only for validators that own an operator account
  - `TEST=y`: allows reading mnemonic seed phrase from env
  > There is a [PR](https://github.com/OLSF/libra/pull/979) that allows reading `MNEM` without setting `TEST=y`
  - `MNEM`: the mnemonic seed phrase generated during account creation

- [Check if an account needs to be created](https://github.com/OLSF/libra/blob/main/ol/documentation/node-ops/tower_mining_VDF_proofs.md)
  This step makes sure we have an account and the data directory `OL_DATA_DIR` contains the required files:
  - `./vdf_proofs/proof_0.json` (and potentially other proofs)
  - `./key_store.json`
  - `./0L.toml`

- To create a new account
  ```shell
  # Generate mnemonic seed phrase
  onboard keygen
  
  # Let someone onboard it using authKey
  
  # Create 0L.toml file
  cd $HOME/.0L
  
  # Initialise configs (requires ol version >= 5.0.12)
  ol init --app --rpc-playlist https://raw.githubusercontent.com/OLSF/seed-peers/main/fullnode_seed_playlist.json

  # Create the first proof and `account.json`, the following will take about 30-40 minutes
  onboard user
  ```

- Use docker-compose to manage `tower` service

  ```shell
  # Start Tower service in background
  docker-compose up -d --no-deps tower

  # Tail logs
  docker-compose logs -f --tail 50 tower
  ```

### Docker-Compose commands

This is a list of some useful commands.

```shell
# Start a shell service with all 0L binaries available
# Useful to run `txs` commands
docker-compose run --rm shell

# Start service(s)
docker-compose up tower 

# You can pass one or more services
docker-compose up node tower monitor

# Start service(s) in background
docker-compose up -d node tower monitor 

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

## Services

### `node` service

> Ports - operations: 6179, 6180, 8080

> Ports - monitoring: 9101, 9102

This service can run as either of: `fullnode`, `validator`, `vfn`. That is determined by the `OL_NODE_MODE` env
variable.

### `tower` service

Tower service can be launched in multiple modes. That depends on whether the accompanying node is fully synced or not.
Validators have operator accounts that can be used to start tower without providing mnemonic phrase for owner account.

- mode 1: initial start uses upstream as fullnode/validator are not yet synced
  > `entrypoint: [ "tower", "--use-upstream-url", "--verbose", "start" ]`

- mode 2: fullnode/validator are synced: run as non-operator (requires MNEM)
  > `entrypoint: [ "tower", "--verbose", "start" ]`
  
  This mode is also meant for miners only as they will be using an upstream fullnode that is synced

- mode 3: fullnode/validator are synced: run as operator
  > `entrypoint: [ "tower", "--is-operator", "--verbose", "start" ]`


### `monitor` service

> Port: 3030

Start web monitor.

### `shell` service

Run different ol and other commands inside an isolated container.


## Notes

### Miners

- When running a **fullnode** or a **validator setup**, `node` service must be running before other services `monitor` and `tower`
  This is not the case for **miners** as they don't need to operate a node.
  Therefore, running tower with `--no-deps` flag is necessary when not operating own fullnode.

- `TEST` variable should not be included in any services other than `tower`
  Pending PR https://github.com/OLSF/libra/pull/979

## Todos

### Docker

- [ ] Use smaller image
- [ ] Security
  - [ ] use non-root user
  - [ ] what else?

### Deployment

- [ ] Create CI to auto build image
