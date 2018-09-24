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

save(naicsCodes, file='data/naicsCodes.RData')
save(naicsNames, file='data/naicsNames.RData')
save(naicsLabels, file='data/naicsLabels.RData')
