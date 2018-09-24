source('defaultValues.R')


makeIndustrySelectionPageUI <- function () {
  naicsCodes <- getData('naicsCodes')
  return(
        checkboxGroupInput("industryChecklist",
                           label = h3("Industry Selector"), 
                           choiceNames=getData('naicsLabels'),
                           choiceValues=naicsCodes,
                           selected = naicsCodes[match(getDefaultValues()$naicsCodes, naicsCodes)])
  )
}