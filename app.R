defaultValues <- list(
  naicsCodes=c(311211, 325193, 311111),
  naicsWeights=c(50, 25, 25)
)

maxNaicsInputs <- 10

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

mfg <- read_excel(
  paste('full-mfg.xlsx', sep=''),
  col_types = 'text'
  #col_types = c('text', 'text', 'numeric', 'numeric', 'text', 'text', 'numeric', 'text', 'numeric', 'numeric', 'date', 'date', 'date', 'date', 'text', 'logical', 'logical', 'logical', rep('text', 4))
)

# Remove the header description row
mfg <- mfg[-1, ]

### Create a list of unique NAICS codes
allNaicsCodes <- mfg %>% pull(NAICS.id)
naicsCodes <- head(unique(allNaicsCodes), 20) # tmp trimming
uniqueRows <- match(naicsCodes, allNaicsCodes)
naicsNames <- (mfg %>% pull(`NAICS.display-label`))[uniqueRows]
naicsLabels <- paste(str_pad(naicsCodes, width=max(nchar(naicsCodes)), side='right', '_'), naicsNames, sep=' : ')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   conditionalPanel(
     condition = 'true == true',
     verbatimTextOutput('currentView')
   ),
   conditionalPanel(
     condition = 'output.currentView != "industrySelectionPage"',
     actionButton('prevPage', label = 'Back')
   ),
   conditionalPanel(
     condition = 'output.currentView != "mapPage"',
     actionButton("nextPage", label = "Next")
   ),
   conditionalPanel(
     condition = 'output.currentView == "industrySelectionPage"',
     sidebarLayout(
       
       sidebarPanel(
         checkboxGroupInput("industryChecklist",
                            label = h3("Industry Selector"), 
                            choiceNames=naicsLabels,
                            choiceValues=naicsCodes,
                            selected = naicsCodes[match(defaultValues$naicsCodes, naicsCodes)]),

         hr(),
         fluidRow(column(3, verbatimTextOutput("value"))),
         width=5
       ),

       mainPanel(
         verbatimTextOutput("test"),
         lapply(1:maxNaicsInputs, function(i) { uiOutput(paste0('naicsWtWidget', i)) })
       )
     )
   )
)

# Define server logic required to draw a histogram
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
    for (i in 1:maxNaicsInputs) {
      current <- getNthNaicsWt(i)
      if (is.null(current) || is.na(current)) current <- 0
      total <- current + total
    }

    return (total)
  }

  lapply(1:maxNaicsInputs, function(i) {
    output[[paste0('naicsWtWidget', i)]] <- renderUI({
      naics <- getNthNaicsCode(i)
      if (is.na(naics)) return()
      textInput(paste0('naicsWt', i), label = h3(paste0('weight for ', naics, ' goes here')), value = "0")
    })
  })

  output$test <- renderPrint({ paste0('TOTAL: ', getTotalNaicsWt()) })
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
