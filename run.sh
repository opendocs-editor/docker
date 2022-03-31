#!/bin/bash

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mPulling images...\e[0m\n"

docker-compose pull

printf "\e[0;34m[\e[0;36mINFO\e[0;34m]\e[0m \e[1;33mRunning containers...\e[0m\n"

docker-compose up