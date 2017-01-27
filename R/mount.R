#' Mount network share on local machine (only works for jjo11 currently)
#'
#' @export
mount <- function() {
    system("mkdir -p /tmp/jjo11")
    if (!dir.exists("/tmp/jjo11/clustr")) {
        system("mount -t smbfs //jjo11@fi--san02.dide.ic.ac.uk/homes/jjo11 /tmp/jjo11", wait = TRUE)
    }
}
