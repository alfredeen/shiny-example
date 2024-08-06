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

    install.packages("log4r")
    install.packages('RcppTOML')
    install.packages('readr')
    install.packages("data.table", dependencies=TRUE)
    library(shiny)
    runApp("app")


## Build a docker image locally

    docker build -t shiny-example:dev .

Run the container

    docker run -p 127.0.0.1:3838:3838 shiny-example:dev

Browse to the app at  http://localhost:3838/


## View the Shiny server log files

    ls /var/log/shiny-server
