# Use an official R runtime as a parent image
FROM rocker/shiny:latest

ENV USER=shiny
ENV HOME=/home/$USER

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


# Copy the appwork directory to the home path
COPY /appwork $HOME/appwork
RUN chown -R shiny:shiny $HOME

# Copy and prepare the Shiny application
RUN rm -rf /srv/shiny-server/*

COPY /app/ /srv/shiny-server/
COPY .Renviron.template /srv/shiny-server/.Renviron

WORKDIR /srv/shiny-server

RUN chown -R shiny:shiny .

# Start the application
WORKDIR /srv/shiny-server/

USER $USER
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
