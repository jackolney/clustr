#' Logout and unmount network share
#'
#' @export
logout <- function() {
    system("umount /tmp/jjo11", wait = TRUE)
}
