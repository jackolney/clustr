#' System call to open network share directory
#'
#' @export
open_remote <- function() {
    if (dir.exists("/tmp/jjo11/clustr")) system("open /tmp/jjo11/clustr")
}
