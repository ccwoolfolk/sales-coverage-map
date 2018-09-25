makeMapPageUI <- function () {
  list(
    imageOutput('mapImage'),
    downloadButton('mapDownloadData', 'Download Excel Data')
  )
}