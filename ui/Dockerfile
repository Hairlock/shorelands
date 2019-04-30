ARG     NODE_VERSION=10.15.0

FROM    node:${NODE_VERSION}

WORKDIR /app
COPY    ./package.json ./
RUN     yarn

COPY    . .
RUN     yarn prod

RUN     yarn global add http-server     
CMD     ["http-server", "dist"]