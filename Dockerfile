FROM alpine:edge

RUN apk add --no-cache hugo nodejs npm

WORKDIR /site

RUN npm install -g http-server

COPY . /site

RUN hugo --minify

EXPOSE 1313

CMD ["http-server", "public", "-p", "1313"]

