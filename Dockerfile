FROM alpine:edge

RUN apk add --no-cache hugo nodejs npm

RUN npm install -g http-server

COPY . /site

WORKDIR /site

RUN hugo --minify

EXPOSE 1313

CMD ["http-server", "public", "-p", "1313"]

