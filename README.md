# shiny-example
A simple example Shiny app written in R.

## Trunk based workflow
In this repo, we work [Trunk based](https://www.toptal.com/software/trunk-based-development-git-flow), which means that we bypass the dev branch.

## Begin

    cd ./shiny-example

If planning to run in local environment from R terminal:
Copy and edit the .Renviron file

    cp ./.Renviron.template ./app/.Renviron

## Running the app in R terminal

Pre-requisites

    Install R, the R language server and R Shiny.
    In VSCode, can install the Shiny extension.

Open an R terminal

    setwd("shiny-example")

Install the R packages

    install.packages(c("log4r", "RcppTOML", "readr"))
    install.packages("data.table", dependencies=TRUE)
    library(shiny);runApp("app")


## Build a docker image locally

    docker build -t shiny-example:dev .

Run the container without mounting a volume (logs and other files in the container):

    docker run --rm -p 127.0.0.1:3838:3838 shiny-example:dev

Or, run the container and also mount a volume for the appwork directory (logs and files on the host).
Make sure to grant write permissions on the appwork dir:

    chmod o+w -R ./appwork

    docker run --rm -p 127.0.0.1:3838:3838 -v ./appwork:/home/shiny/appwork  shiny-example:dev


Browse to the app at  http://localhost:3838/


## Custom app type

### Build and publish a special custom docker image

Build a custom image that can be deployed as a custom app type

    docker build -t shiny-example:custom-dev -f Dockerfile.custom .

Run the container

    docker run --rm -p 127.0.0.1:3838:3838 shiny-example:custom-dev

Browse to the app at  http://localhost:3838/

### Create a Custom App in Serve

Follow the normal instructions. After the app has been created, change the
user id to the expected user id = 1000 for custom apps (from shiny 999).

Re-deploy the app.


## Log files

### View the custom app log file

    tail /srv/shiny-server/rlogs/app.log -f

### View the Shiny server log files

    ls /var/log/shiny-server
