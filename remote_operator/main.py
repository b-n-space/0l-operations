from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"Hello": "0L Operator!"}


@app.post("/restart")
def restart():
    return {"not": "implemented"}


@app.post("/cron/on")
def cron_on():
    return {"not": "implemented"}


@app.post("/cron/off")
def cron_off():
    return {"not": "implemented"}


@app.patch("/ol-toml")
def patch_ol_toml():
    return {"not": "implemented"}


@app.patch("/validator-yaml")
def patch_validator_yaml():
    return {"not": "implemented"}
