FROM node:8-alpine

LABEL mantainer "Diego Dorgam <diego.dorgam@rocket.chat>"

ENV NATURAL_LANG='en'                                           \
    NATURAL_CORPUS='training_data/corpus.yml'                   \
    HUBOT_ADAPTER=rocketchat                                    \
    HUBOT_OWNER=RocketChat                                      \
    HUBOT_NAME=HubotNatural                                     \
    HUBOT_DESCRIPTION="Natural Language Processing with hubot"  \
    HUBOT_LOG_LEVEL=debug                                       \
    ROCKETCHAT_URL=http://rocketchat:3000                       \
    ROCKETCHAT_USESSL='false'                                   \
    ROCKETCHAT_ROOM=GENERAL                                     \
    ROCKETCHAT_USER=bot-username                                \
    ROCKETCHAT_PASSWORD=bot-password                            \
    ROCKETCHAT_AUTH=password                                    \
    RESPOND_TO_DM=true                                          \
    RESPOND_TO_LIVECHAT=true                                    \
    RESPOND_TO_EDITED=true                                      \
    LISTEN_ON_ALL_PUBLIC=true


workdir hubotnatural

add . /hubotnatural

run apk --update add --no-cache --virtual build-dependencies    \
                     git make gcc g++ python                 && \
    npm install                                              && \
    apk del build-dependencies

entrypoint bin/hubot
