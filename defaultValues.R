getDefaultValues <- function() {
  list(
    naicsCodes=c(3111, 31121, 325193, 327),
    naicsWeights=c(0.2, 0.4, 0.1, 0.2)*100
  )
}

getMaxNaicsInputs <- function() {
  return (10)
}
