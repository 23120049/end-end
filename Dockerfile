FROM nginx:1.30.6-alpine

ARG RELEASE_VERSION
ARG GIT_SHA
ARG IMAGE_CREATED_AT

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/

RUN sed \
    -e "s|__RELEASE_VERSION__|${RELEASE_VERSION}|g" \
    -e "s|__GIT_SHA__|${GIT_SHA}|g" \
    -e "s|__IMAGE_CREATED_AT__|${IMAGE_CREATED_AT}|g" \
    /usr/share/nginx/html/index.html \
    > /tmp/index.html \
    && mv /tmp/index.html /usr/share/nginx/html/index.html

EXPOSE 8080
