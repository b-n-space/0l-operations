FROM python:3.11-slim-bullseye

ENV PYTHONUNBUFFERED 1

# Install pip requirements
COPY ./tools.requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Define working directory
RUN mkdir /code
WORKDIR /code

# Expose Uvicorn port
EXPOSE 3333

# Command to serve API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3333"]
