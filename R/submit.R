#' Submit job to DIDE cluster
#'
#' @param q queue from didewin
#'
#' @param x function to run on the cluster
#'
#' @export
submit <- function(q = obj, x) {
    q$enqueue(x)
    message(q$task_id())
    q
}
