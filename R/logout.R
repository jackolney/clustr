#' Logout and unmount network share
#'
#' @param username DIDE username
#'
#' @export
logout <- function(username) {
    system(paste0("umount /tmp/", username), wait = TRUE)
}
