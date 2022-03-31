#!/bin/bash

set -e

LOADCMD=" --load"

if [[ "$*" == *"--push"* ]]; then
    LOADCMD=" --push"
fi

if [[ "$*" == *"--clean"* ]]; then
    printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mCleaning cache...\e[0m\n"
    docker buildx prune -af || exit 1
fi

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mBuilding API server...\e[0m\n"

docker buildx build -t redstonewizard/opendocs-api:latest${LOADCMD} -f Dockerfile.api .

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mBuilding proxy server...\e[0m\n"

docker buildx build -t redstonewizard/opendocs-proxy:latest${LOADCMD} -f Dockerfile.proxy .

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mBuilding frontend app...\e[0m\n"

docker buildx build -t redstonewizard/opendocs-frontend:latest${LOADCMD} -f Dockerfile.frontend .

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mDone!...\e[0m\n"
