FROM elixir:1.7-alpine

RUN apk add --update --no-cache bash build-base git yarn postgresql-client inotify-tools \
      && mix local.hex --force \
      && mix local.rebar --force

WORKDIR /app
ADD . /app

RUN mix deps.get -y && mix deps.compile
RUN cd ./assets/ && yarn install && cd /app

EXPOSE 4000

CMD ["mix", "phx.server"]
