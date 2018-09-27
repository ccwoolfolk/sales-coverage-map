

getData <- function (name) {
  mfg <- demandmap::getData()
  
  ### Create a list of unique NAICS codes
  allNaicsCodes <- mfg %>% pull(NAICS.id)
  naicsCodes <- unique(allNaicsCodes)
  naicsCodes <- naicsCodes[order(naicsCodes)]
  if (name == 'naicsCodes') return(naicsCodes)
  
  uniqueRows <- match(naicsCodes, allNaicsCodes)
  naicsNames <- (mfg %>% pull(`NAICS.display-label`))[uniqueRows]
  if (name == 'naicsNames') return(naicsNames)
  
  naicsLabels <- paste(str_pad(naicsCodes, width=max(nchar(naicsCodes)), side='right', '_'), naicsNames, sep=' : ')
  if (name == 'naicsLabels') return(naicsLabels)

  stop('"name" not recognized')
}

### TODO: is this duplicative with getData('naicsLabels') ?
getNaicsLabels <- function(codes) {
  naicsCodes <- getData('naicsCodes')
  naicsNames <- getData('naicsNames')
  idxs <- match(codes, table=naicsCodes)
  return(naicsNames[idxs])
}
