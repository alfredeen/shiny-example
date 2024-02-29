# shiny-example
A simple example Shiny app written in R.

## Begin

    cd ./shiny-example

## Running the app in R terminal

Open an R terminal

    setwd("shiny-example")
    install.packages("log4r")
    library(shiny)
    runApp("app")

## Build a docker image locally

    docker build -t shiny-example:dev .

Run the container

    docker run -p 127.0.0.1:3838:3838 shiny-example:dev

Browse to the app at  http://localhost:3838/app

## View the log files

    ls /var/log/shiny-server
