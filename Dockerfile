# Use an official R runtime as a parent image
FROM rocker/shiny:latest

ENV USER=shiny

# Install system dependencies including those for tidyverse
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git libxml2-dev libmagick++-dev \
    wget libgomp1 \  
    libssl-dev \     
    make \
    pandoc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('log4r')"

RUN rm -rf /srv/shiny-server/*
COPY /app/ /srv/shiny-server/app

RUN cd /srv/shiny-server/ && \
    sudo chown -R shiny:shiny /srv/shiny-server/app

WORKDIR /srv/shiny-server/app

USER $USER
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]