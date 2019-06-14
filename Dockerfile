FROM alpine:edge

RUN apk add --no-cache hugo

COPY . /site

WORKDIR /site

EXPOSE 1313

CMD ["hugo", "server", "--environment", "production", "--bind", "0.0.0.0", "--port", "1313", "--appendPort=false", "--baseURL", "/"]

