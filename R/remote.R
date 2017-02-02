#' System call to open network share directory
#'
#' @param username DIDE username
#'
#' @param remotewd remote directory on network share (don't require entire path)
#'
#' @export
open_remote <- function(username, remotewd) {
    if (dir.exists(file.path("/tmp", username, remotewd))) system(paste("open", file.path("/tmp",
       username, remotewd)))
}
