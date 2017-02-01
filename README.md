### clustr

A place to store scripts for automating [CascadeDashboard](https://github.com/jackolney/CascadeDashboard) using the MRC cluster.

Relies heavily on [Rich's](https://github.com/richfitz) [didewin](https://github.com/dide-tools/didewin) tools!

This is really for internal use and will not be that useful to anyone else.


```R

## login to cluster (as me currently)
# args:
# cwd = set current working directory
# remotewd = remote directory on network share
# cluster = select cluster 'fi--didemrchnb' or 'fi--dideclusthn'
# log = boolean to set logging
clustr::login()

## mount network share
# function called by login()
clustr::mount()

## open mounted network share
clustr::open_remote()

## umount network share
clustr::logout()

## submit job to cluster
# wrapper around obj$enqueue()
# still in development
clustr::submit()

```
