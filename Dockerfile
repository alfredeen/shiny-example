# Use an official R runtime as a parent image
FROM rocker/shiny:latest

ENV USER=shiny

# Install system dependencies including those for tidyverse
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    git libxml2-dev libmagick++-dev \
    wget libgomp1 \  
    libssl-dev \     
    make \
    pandoc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('log4r')" \
    && R -e "install.packages('readr')" \
    && R -e "install.packages('data.table')" \
    && R -e "install.packages('RcppTOML')"

RUN mkdir logs \
    && chown -R shiny:shiny /logs

RUN rm -rf /srv/shiny-server/*
COPY /app/ /srv/shiny-server/app

WORKDIR /srv/shiny-server

#RUN cd /srv/shiny-server/ && \

RUN chown -R shiny:shiny /srv/shiny-server/app

WORKDIR /srv/shiny-server/app

USER $USER
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
