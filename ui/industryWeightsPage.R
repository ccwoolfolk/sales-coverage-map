source('defaultValues.R')

makeIndustryWeightsPageUI <- function () {
  list(
      verbatimTextOutput('weightsTotalDisplay'),
      lapply(1:getMaxNaicsInputs(), function(i) { uiOutput(paste0('naicsWtWidget', i)) })
  )
}