source('defaultValues.R')

makeIndustrySelectionPageUI <- function () {
  return(
        checkboxGroupInput("industryChecklist",
                           label = h3("Industry Selector"), 
                           choiceNames=naicsLabels,
                           choiceValues=naicsCodes,
                           selected = naicsCodes[match(getDefaultValues()$naicsCodes, naicsCodes)])
  )
}