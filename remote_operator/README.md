# 0L-Remote-Operator

## Goal

Allows 0L node operators to perform critical operations remotely.

## Terms

- Local operator: entity owning or running an 0L node
- Remote operator: entity with permission to perform remote operations on an 0L node setup

## Tech

- Backend (Python)
  - [FastAPI](https://fastapi.tiangolo.com/) for exposing API endpoints
  - [pydantic](https://pydantic-docs.helpmanual.io/) for data validation and settings management
- Frontend (Javascript)
  - Single HTML page running [Vue](https://vuejs.org/) app
  - Optional: [Buefy components](https://buefy.org/) based on[Bulma](http://bulma.io/)

## Deployment

- Extra service in 0l-operations' [docker-compose](../docker-compose.yml)
- Based on [3.11.0-slim-bullseye](https://hub.docker.com/_/python/tags?page=1&name=3.11.0-slim-bullseye) docker image
- Only python requirements are installed in the image
- Source code resides in the repo and gets mounted as a host volume

## Features

- Restarting node and other services
- Managing cron: start, stop
- Updating specific values in `0L.toml`
- Updating specific values in `validator.node.yaml`
- else?

## Security concerns and measures

- Source code is always auditable by node operators
  - Python is chosen to be clearly interpreted
  - Docker image only provides runtime environment
- Local operators must create firewall rules to only allow traffic from trusted sources to particular ports
- Entire request bodies are validated not allowing any arbitrary payloads
- All endpoints are auth protected; preferably JWT with short expiry
  - Basic auth endpoint to acquire JWT token
- Each operation must
  - provide a reason
  - creates a backup of files it has modified

## Questions

- How many are currently using the 0l-operations setup? in general, we want a statistic on different setups being used
- What other security concerns do we have?

## Tasks

- [ ] Collect more info
- [ ] Finalise features
- [ ] Add basic auth
- [ ] Publish initial version with restart feature
- [ ] Implement logging and backups
