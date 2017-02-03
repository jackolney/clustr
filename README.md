### clustr

A place to store scripts for automating access to the DIDE cluster.

Works as a wrapper around [Rich's](https://github.com/richfitz) great [didewin](https://github.com/dide-tools/didewin) tools!

This is really for internal use and will not be that useful to anyone else.


```R

## login to cluster (didewin config and login)
clustr::login(username = "dide_username",
              remotewd = "directory_on_network_share",
              sources = c("source_files.R"),
              packages = c("devtools", "other_package_name"),
              cluster = "MRC",
              log = TRUE)

## mount network share
clustr::mount(username, remotewd)

## open mounted network share
clustr::open_remote(username, remotewd)

## umount network share
clustr::logout(username)

## submit job to cluster
# wrapper around obj$enqueue()
# still in development
clustr::submit(obj, x)

```
