FROM node:8-alpine

LABEL mantainer "Diego Dorgam <diego.dorgam@rocket.chat>"

ENV NATURAL_LANG='en'                                                  \
    NATURAL_CORPUS='training_data/corpus.yml'                          \
    HUBOT_ADAPTER=rocketchat                                         \
    HUBOT_OWNER=RocketChat                                           \
    HUBOT_NAME=HubotNatural                                          \
    HUBOT_DESCRIPTION="Processamento de linguagem natural com hubot" \
    HUBOT_LOG_LEVEL=debug                                            \
    ROCKETCHAT_URL=http://rocketchat:3000                            \
    ROCKETCHAT_USESSL='false'                                         \
    ROCKETCHAT_ROOM=GENERAL                                          \
    ROCKETCHAT_USER=bot-username                                          \
    ROCKETCHAT_PASSWORD=bot-password                                     \
    ROCKETCHAT_AUTH=password                                         \
    RESPOND_TO_DM=true                                               \
    RESPOND_TO_LIVECHAT=true                                         \
    RESPOND_TO_EDITED=true                                           \
    LISTEN_ON_ALL_PUBLIC=true

RUN apk --update add --no-cache git make gcc g++ python python-dev && \
    addgroup -S hubotnat && adduser -S -g hubotnat hubotnat

RUN npm install -g yo generator-hubot@1.0.0 node-gyp

WORKDIR /home/hubotnat/bot

USER root

RUN mkdir -p /home/hubotnat/.config/configstore                             && \
    echo "optOut: true" > /home/hubotnat/.config/configstore/insight-yo.yml && \
    chown -R hubotnat:hubotnat /home/hubotnat

USER hubotnat

RUN yo hubot --adapter ${HUBOT_ADAPTER}         \
             --owner ${HUBOT_OWNER}             \
             --name ${HUBOT_NAME}               \
             --description ${HUBOT_DESCRIPTION} \
             --defaults --no-insight         && \
    rm /home/hubotnat/bot/external-scripts.json

COPY ["package.json", "/home/hubotnat/bot/"]

ADD scripts/ /home/hubotnat/bot/scripts/

ADD training_data/ /home/hubotnat/bot/training_data

RUN npm install --save

ENTRYPOINT /home/hubotnat/bot/bin/hubot -a ${HUBOT_ADAPTER} -n ${HUBOT_NAME} -l ${ROCKETCHAT_USER}
