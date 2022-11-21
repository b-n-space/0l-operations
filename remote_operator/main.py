import json
from enum import Enum

from fastapi import FastAPI
from pydantic import BaseModel, create_model

app = FastAPI(title="OL Remote Operator", version="0.0.1")


@app.get("/")
def root():
    return {"Hello": "0L Operator!"}


class OperationType(str, Enum):
    """
    Operation types

    cmd: run a command and return its output
    patch: given a filename, update part of its content

    """
    CMD = 'cmd'
    PATCH = 'patch'


class BaseOperation(BaseModel):
    name: str
    description: str
    method: str
    type: OperationType
    checks: list[str] = []


class CmdOperation(BaseOperation):
    cmd: list[str] = None
    filename: str = None
    payload: str = None


class PatchOperation(BaseOperation):
    cmd: list[str] = None
    filename: str = None
    payload: str = None


class BaseRequest(BaseModel):
    reason: str


# Load operations schema
with open("operations.json") as f:
    operations = json.load(f)

for op_dict in operations:
    op: BaseOperation = BaseOperation.parse_obj(op_dict)

    # Create request model
    request_model_attrs = {
        '__base__': BaseRequest,
    }
    # Create response model

    if op.type == OperationType.CMD:
        op: CmdOperation = CmdOperation.parse_obj(op)

    elif op.type == OperationType.PATCH:
        op: PatchOperation = PatchOperation.parse_obj(op)
        # create payload model based on schema from op.payload

    OperationRequestModel = create_model(f"Request{op.name.capitalize()}", **request_model_attrs)

    # Create endpoint

    def endpoint(data: OperationRequestModel):
        if op.type == OperationType.CMD:
            output = 1
        elif op.type == OperationType.PATCH:
            output = 2

        return {
            "operation": op.name,
            "description": op.description,
            "not": "implemented",
            "output": output
        }


    # Add endpoint to api
    app.add_api_route(
        path=f"/{op.name}",
        methods=[op.method],
        endpoint=endpoint,
        name=f"{op.name.capitalize()} Endpoint",
        description=op.description
    )
