library(shiny)
library(readr)
library(log4r)
library(RcppTOML)
library(data.table)

print("Begin app.R")

# Settings from env vars
log_level <- "DEBUG"
log_file <- "/rlogs/app.log"

tryCatch({
  print("Reading environment variables from .Renviron")

  readRenviron(".Renviron")

  log_level <- Sys.getenv("R_LOGLEVEL")
  log_file <- Sys.getenv("R_LOGFILE")

}, error=function(e) {
  print(paste("Error while trying to get env vars ", e))
}, warning=function(e) {
  print(paste("Warning while trying to get env vars ", e))
})

# Logging
print(paste("Running app with log level = ", log_level, ". Logging to ", log_file))

logger <- log4r::logger(appenders = file_appender(log_file))

log4r::info(logger, paste("START app.R. Logging enabled with log level =", log_level))

# Version
# Get the version nr from the project toml file
ver <- "unset"
project_filename <- "project.toml"

tryCatch({
  fd <- read_file(project_filename)
  toml <- parseTOML(fd, verbose = FALSE, fromFile=FALSE, includize=FALSE, escape=TRUE)
  ver <- toml["app"]$app$version
  log4r::info(logger, paste("Running app version =", ver))
}, error=function(e) {
  log4r::warn(logger, e)
}, warning=function(e) {
  log4r::warn(logger, e)
})


# Verify can create a directory and write to it
dir_appwork <- "appwork"

tryCatch({

  print(paste("print: Creating directory ", dir_appwork))
  log4r::debug(logger, paste("Creating directory ", dir_appwork))

  if (!dir.exists(dir_appwork)){
    dir.create(dir_appwork, showWarnings = TRUE, recursive = TRUE)
  } else {
    print("Directory appwork already exists.")
    log4r::debug(logger, paste("Directory appwork already exists: ", dir_appwork))
  }
}, error=function(e) {
    log4r::warn(logger, e)
}, warning=function(e) {
    log4r::warn(logger, e)
})


work_filename <- "df.csv"

df <- data.frame(var1=c(1, 2, 3, 4, 5),
                 var2=c(6, 7, 8, 9, 0))

tryCatch({

  work_path <- paste(dir_appwork, work_filename, sep="/")
  print(paste("print: Creating file ", work_path))
  log4r::debug(logger, paste("Creating file ", work_path))
  fwrite(df, file=work_path)

}, error=function(e) {
  log4r::warn(logger, e)
}, warning=function(e) {
  log4r::warn(logger, e)
})



# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel("Hello Shiny!"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)

    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Histogram ----
      plotOutput(outputId = "distPlot")

    ),

  ),
  # Footer
  hr(),
  div(
      class = "footer",
      paste("version ", ver)
      # includeHTML("www/footer.html")
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  output$distPlot <- renderPlot({

    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")

    })

}

# Run the Shiny app
shinyApp(ui = ui, server = server)
