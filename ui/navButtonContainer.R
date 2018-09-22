makeNavButtonContainerUI <- function () {
  list(
    div(style='display: inline-block',
        conditionalPanel(
          condition = 'output.currentView != "industrySelectionPage"',
          actionButton('prevPage', label = 'Back')
        )
    ),
    div(style='display: inline-block',
        conditionalPanel(
          condition = 'output.currentView != "mapPage"',
          actionButton("nextPage", label = "Next")
        )
    )
  )
}