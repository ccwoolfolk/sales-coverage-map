library(shiny)
library(stringr)
library(readxl, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(demandmap)
#library(zoo, quietly = TRUE, warn.conflicts = FALSE)
#library(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
#library(bindrcpp, quietly=TRUE, warn.conflicts=FALSE)
#library(quantmod)
#library(plotrix)
#library(maps)
#library(rlang)

source('defaultValues.R')
source('dataHelpers.R')


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
      fluidRow(
        column(width=2, textInput(paste0('naicsWt', i), value = "0", label=NULL)),
        column(width=10, p(getNaicsLabels(naics)))
      )
    })
  })

  output$industryWeightsTotal <- renderUI({
    total <- round(getTotalNaicsWt(), 0)
    baseContent <- tags$h3(paste0('Total weights: ', total, '%'))
    if (total == 100) {
      return(tagList(baseContent))
    }
    warningMessage <- tags$p(style='color: #FF0000;', 'Total should equal 100%.')
    tagList(baseContent, warningMessage)
  })

  output$currentView <- reactive({
    pages <- c(
      'industrySelectionPage',
      'industryWeightsPage',
      'mapPage'
    )
    stepsForward <- min(length(pages), max(0, input$nextPage + 1 - input$prevPage))
    pages[stepsForward]
  })
  
  output$mapImage <- renderPlot({
    codes <- c()
    wts <- c()
    for (i in 1:getMaxNaicsInputs()) {
      if (is.na(getNthNaicsCode(i))) break
      codes[i] <- getNthNaicsCode(i)
      wts[i] <- getNthNaicsWt(i)
    }
    
    rawData <- demandmap::getData()
    indWts <- demandmap::makeWeightsInput(
      labels=codes,
      weights=wts
    )
    metWts <- demandmap::makeWeightsInput(
      labels=c('ESTAB', 'EMP'),
      weights=c(0.5, 0.5)
    )

    stateScores <- data2stateScores(
      rawData,
      industryWeights=indWts,
      metricWeights=metWts
    )
    
    gg <- demandmap::plotDemandMap(
      stateScoresData=stateScores,
      mapData=ggplot2::map_data('state')
    )

    gg
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

