FROM alpine:edge

RUN apk add --no-cache hugo

COPY . /site

WORKDIR /site

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0"]

