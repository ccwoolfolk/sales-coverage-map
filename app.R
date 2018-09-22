library(shiny)
library(stringr)
library(readxl, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
#library(zoo, quietly = TRUE, warn.conflicts = FALSE)
#library(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
#library(bindrcpp, quietly=TRUE, warn.conflicts=FALSE)
#library(quantmod)
#library(plotrix)
#library(maps)
#library(rlang)

source('defaultValues.R')

mfg <- read_excel(
  paste('full-mfg.xlsx', sep=''),
  col_types = 'text'
)

# Remove the header description row
mfg <- mfg[-1, ]

### Create a list of unique NAICS codes
allNaicsCodes <- mfg %>% pull(NAICS.id)
naicsCodes <- unique(allNaicsCodes)
uniqueRows <- match(naicsCodes, allNaicsCodes)
naicsNames <- (mfg %>% pull(`NAICS.display-label`))[uniqueRows]
naicsLabels <- paste(str_pad(naicsCodes, width=max(nchar(naicsCodes)), side='right', '_'), naicsNames, sep=' : ')

source('ui/navButtonContainer.R')
source('ui/industrySelectionPage.R')
source('ui/industryWeightsPage.R')
source('ui/mapPage.R')

ui <- fluidPage(
   titlePanel('Sales Coverage Visualization'),
   sidebarLayout(
     sidebarPanel(
       width=3,
       conditionalPanel(
         condition = 'true',
         verbatimTextOutput('currentView')
       ),
       makeNavButtonContainerUI()
     ),
     mainPanel(
       conditionalPanel(
         condition = 'output.currentView == "industrySelectionPage"',
         makeIndustrySelectionPageUI()
       ),
       conditionalPanel(
         condition = 'output.currentView == "industryWeightsPage"',
         makeIndustryWeightsPageUI()
       ),
       conditionalPanel(
         condition = 'output.currentView == "mapPage"',
         makeMapPageUI()
       )
     )
   )
)

server <- function(input, output) {
  # Create a list of text inputs for naics weights
  getNthNaicsCode <- function (i) {
    return(input$industryChecklist[i])
  }
  
  getNthNaicsWt <- function (i) {
    rawValue <- as.numeric(input[[paste0('naicsWt', i)]])
    if (length(rawValue) == 0) return (0)
    return(rawValue)
  }
  
  getTotalNaicsWt <- function () {
    total <- 0
    for (i in 1:getMaxNaicsInputs()) {
      current <- getNthNaicsWt(i)
      if (is.null(current) || is.na(current)) current <- 0
      total <- current + total
    }

    return (total)
  }

  lapply(1:getMaxNaicsInputs(), function(i) {
    output[[paste0('naicsWtWidget', i)]] <- renderUI({
      naics <- getNthNaicsCode(i)
      if (is.na(naics)) return()
      textInput(paste0('naicsWt', i), label = h3(paste0('weight for ', naics, ' goes here')), value = "0")
    })
  })

  output$weightsTotalDisplay <- renderPrint({ paste0('TOTAL: ', getTotalNaicsWt()) })

  output$currentView <- reactive({
    pages <- c(
      'industrySelectionPage',
      'industryWeightsPage',
      'mapPage'
    )
    stepsForward <- min(length(pages), max(0, input$nextPage + 1 - input$prevPage))
    pages[stepsForward]
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

