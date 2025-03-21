library(shiny)
library(readr)
library(log4r)
library(RcppTOML)
library(data.table)

print(paste("Begin app.R. Running in working dir =", getwd()))


# Settings from env vars
appwork_path <- "/home/shiny/appwork"
log_level <- "DEBUG"
log_filename <- "app.log"

tryCatch({
  print("Reading environment variables from .Renviron")

  readRenviron(".Renviron")

  appwork_path <- Sys.getenv("APPWORK_PATH")
  log_level <- Sys.getenv("R_LOGLEVEL")
  log_filename <- Sys.getenv("R_LOGFILENAME")

}, error=function(e) {
  print(paste("Error while trying to get env vars", e))
}, warning=function(e) {
  print(paste("Warning while trying to get env vars", e))
})


print(paste("Path to the work directory appwork set to", appwork_path))

# Text to be displayed in footer
dev_msg <- ""

# Logging. Write to a local log file.
# log_file <- paste(appwork_path, "rlogs", log_filename, sep = "/")
log_file <- paste("rlogs", log_filename, sep = "/")

print(paste("Running app with log level =", log_level, ". Logging to", log_file))

logger <- log4r::logger(log_level, appenders = file_appender(log_file))

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


# Function to count the number of files in a directory
count_files <- function(path) {
  print(paste("Counting files in dir: ", path))
  log4r::debug(logger, paste("Counting files in path:", path))

  tryCatch({

    files <- list.files(path, pattern = ".", all.files = FALSE)
    return(length(files))

  }, error=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "warning existing-file.txt.", sep = " ")
    return("error")
  }, warning=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "error existing-file.txt.", sep = " ")
    return("warning")
  })
}

# Function to verify can read a file in a directory
detect_file <- function(filepath) {
  print(paste("print: Verifying that file exists: ", filepath))
  log4r::debug(logger, paste("Verifying that file exists:", filepath))

  tryCatch({

    file_exists <- file.exists(filepath)
    dev_msg <- paste(dev_msg, "file exists existing-file.txt.", sep = " ")
    return(file_exists)

  }, error=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "warning existing-file.txt.", sep = " ")
    return("error")
  }, warning=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "error existing-file.txt.", sep = " ")
    return("warning")
  })
}

# Function to can create dir and write file
create_file <- function(dir_apptemp) {

  print(paste("print: Creating directory", dir_apptemp))
  log4r::debug(logger, paste("Creating directory:", dir_apptemp))

  tryCatch({

    if (!dir.exists(dir_apptemp)){
      dir.create(dir_apptemp, showWarnings = TRUE, recursive = TRUE)
      dev_msg <- paste(dev_msg, "created apptemp.", sep = " ")
    } else {
      print("Directory apptemp already exists.")
      log4r::debug(logger, paste("Directory apptemp already exists:", dir_apptemp))
      dev_msg <- paste(dev_msg, "apptemp existed.", sep = " ")
    }
  }, error=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "warning apptemp.", sep = " ")
    return("error creating/checking dir")
  }, warning=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "error apptemp.", sep = " ")
    return("warning creating/checking dir")
  })

  work_filename <- "df.csv"

  df <- data.frame(var1=c(1, 2, 3, 4, 5),
                   var2=c(6, 7, 8, 9, 0))

  tryCatch({

    work_path <- paste(dir_apptemp, work_filename, sep="/")
    print(paste("print: Creating file", work_path))
    log4r::debug(logger, paste("Creating file:", work_path))
    fwrite(df, file=work_path)
    dev_msg <- paste(dev_msg, "wrote df.", sep = " ")

  }, error=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "warning df.", sep = " ")
    return(paste("error creating file: ", work_filename))
  }, warning=function(e) {
    log4r::warn(logger, e)
    dev_msg <- paste(dev_msg, "error df.", sep = " ")
    return(paste("warning creating file: ", work_filename))
  })

}


# Verify can access existing file
# Also count nr of files in dir
existing_dir <- paste(appwork_path, "existingdir", sep = "/")
existing_file <- paste(existing_dir, "existing-file.txt", sep = "/")

# Verify can create a new directory in dir appwork and write to it
dir_apptemp <- paste(appwork_path, "apptemp", sep = "/")




# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel("Shiny Example"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30),

      p(actionButton("reset_button", "Reset Tool")),
      p(actionButton("btnIdentifyFiles", "Identify files")),
      p(actionButton("btnDetectFile", "Detect existing file")),
      p(actionButton("btnCreateFile", "Create file"))
    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Histogram ----
      plotOutput(outputId = "distPlot"),

      textOutput("currentTime"),
      textOutput("nrFilesFound"),
      textOutput("detectFileMsg"),
      textOutput("createFileMsg")
    ),

  ),
  # Footer
  hr(),
  div(
      class = "footer",
      paste("version ", ver),
      paste("build time: ", format(Sys.time(), "%H:%M:%S")),
      p(paste("log level from envvar = ", log_level)),
      p(paste("info:", dev_msg))
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

  # Display the current time
  output$currentTime <- renderText({
    paste("Current time: ", format(Sys.time(), "%H:%M:%S"))
  })

  # User initiated actions:
  # Button to count files
  output$nrFilesFound <- eventReactive(input$btnIdentifyFiles, {
    paste("Nr files found in (existing_dir): ", count_files(existing_dir))
  })

  # Button to detect an existing file
  output$detectFileMsg <- eventReactive(input$btnDetectFile, {
    paste("Detect file output: ", detect_file(existing_file))
  })

  # Button to create a file
  output$createFileMsg <- eventReactive(input$btnCreateFile, {
    paste("Create file output: ", create_file(dir_apptemp))
  })

  #Refresh button
  observeEvent(input$refresh, {
    session$reload()
    return()
  })

}

# Run the Shiny app
shinyApp(ui = ui, server = server)
