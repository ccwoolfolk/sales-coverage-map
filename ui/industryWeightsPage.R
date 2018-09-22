source('defaultValues.R')

makeIndustryWeightsPageUI <- function () {
  list(
    htmlOutput('industryWeightsTotal'),
    lapply(1:getMaxNaicsInputs(), function(i) { uiOutput(paste0('naicsWtWidget', i)) })
  )
}