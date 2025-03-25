# Use an official R runtime as a parent image
FROM rocker/shiny:4.4.1

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


# Ensure that the expected user is present in the container
RUN if id shiny 2>/dev/null 1>/dev/null && [ "$(id -u shiny)" -ne 999 ]; then \
        userdel -r shiny; \
        id -u 999 2>/dev/null 1>/dev/null && userdel -r "$(id -un 999)"; \
    fi; \
    useradd -u 999 -m -s /bin/bash shiny; \
    chown -R shiny:shiny /var/lib/shiny-server/ /var/log/shiny-server/

# Copy the appwork directory to the home path
# Also copy and prepare the Shiny application
COPY /appwork $HOME/appwork
RUN chown -R shiny:shiny $HOME \
    && rm -rf /srv/shiny-server/* 

COPY /app/ /srv/shiny-server/
COPY .Renviron.template /srv/shiny-server/.Renviron
RUN chown -R shiny:shiny /srv/shiny-server/

WORKDIR /srv/shiny-server

# RUN chown -R shiny:shiny .

# Start the application
WORKDIR /srv/shiny-server/

USER $USER
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
