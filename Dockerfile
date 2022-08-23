FROM docker.io/library/nginx:alpine

# metadata
ARG VCS_REF=master
ARG BUILD_DATE=""
ARG REGISTRY_PATH=docker.io/paritytech
ARG PROJECT_NAME=""
ARG SCHILDI_DIR=""

LABEL io.parity.image.authors="cicd-team@parity.io" \
    io.parity.image.vendor="Parity Technologies" \
    io.parity.image.title="${REGISTRY_PATH}/${PROJECT_NAME}" \
    io.parity.image.description="schildichat-desktop web" \
    io.parity.image.source="https://github.com/paritytech/${PROJECT_NAME}/blob/${VCS_REF}/Dockerfile" \
    io.parity.image.documentation="https://github.com/paritytech/${PROJECT_NAME}/blob/${VCS_REF}/README.md" \
    io.parity.image.revision="${VCS_REF}" \
    io.parity.image.created="${BUILD_DATE}"

WORKDIR /app

COPY ${SCHILDI_DIR}/ /app/

# Override default nginx config
COPY default.conf /etc/nginx/conf.d/default.conf

RUN rm -rf /usr/share/nginx/html \
    && ln -s /app /usr/share/nginx/html
