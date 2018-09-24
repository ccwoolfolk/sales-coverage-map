getData <- function (name) {
  tmpEnv <- new.env()
  load(file=paste0('data/', name, '.RData'), envir=tmpEnv)
  return(get(name, envir=tmpEnv))
}

getNaicsLabels <- function(codes) {
  naicsCodes <- getData('naicsCodes')
  naicsNames <- getData('naicsNames')
  idxs <- match(codes, table=naicsCodes)
  return(naicsNames[idxs])
}