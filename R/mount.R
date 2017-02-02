#' Mount network share on local machine (only works for jjo11 currently)
#'
#' @param username DIDE username
#'
#' @param remotewd remote directory on network share (don't require entire path)
#'
#' @export
mount <- function(username, remotewd) {
    system(paste0("mkdir -p /tmp/", username))
    if (!dir.exists(file.path("/tmp", username, remotewd))) {
        system(paste0("mount -t smbfs //", username, "@fi--san02.dide.ic.ac.uk/homes/", username, " /tmp/",
       username), wait = TRUE)
    }
}
