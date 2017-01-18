PushClusterOptimisation <- function() {
    # setup

    # pass to cluster
    t <- obj$enqueue(
        RunClusterOptimisation()
        # Whatever the fuck this function takes as an arguement
    )

    # print task_id
    message(paste("task_id:", t$id))

    # return t
    return(t)
}
