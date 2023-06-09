ARG PYTHON_VERSION=3.8

FROM jrottenberg/ffmpeg:4.2-alpine as ffmpeg

# Builder
FROM python:${PYTHON_VERSION}-alpine as builder

RUN apk add --update curl git build-base libffi-dev

WORKDIR /root

# Install requirements
COPY requirements.txt /root
RUN pip install --prefix="/install" --no-warn-script-location -r requirements.txt

# Runtime
FROM python:${PYTHON_VERSION}-alpine

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install FFmpeg
COPY --from=ffmpeg / /

# Copy pip requirements
COPY --from=builder /install /usr/local

WORKDIR /app
COPY nazurin ./nazurin

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

CMD ["python", "-m", "nazurin"]
