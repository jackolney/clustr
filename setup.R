# dide-tools didewin setup
# trial with CascadeDashboard

setwd("~/git/clustr")

devtools::install_github(
    c(
        "richfitz/ids",
        "dide-tools/context",
        "richfitz/queuer",
        "dide-tools/didewin"
    )
)

# Add 'syncr' for 'Running out of place'
install.packages("syncr",
    repos = c(
        CRAN = "https://cran.rstudio.com",
        drat = "https://richfitz.github.io/drat"
    )
)

# Supply a working directory to remote network share
workdir <- "/Volumes/jjo11/clustr"

# global config
didewin::didewin_config_global(credentials = "jjo11",
                               cluster = "fi--didemrchnb",
                               workdir = workdir)

didewin::web_login()

# create a root (this should make a root dir 'contexts')
root <- file.path(workdir, "contexts")

# name the package I need (GH)
packages <- c("cascade", "CascadeDashboard", "devtools")

# containing function definitions -> point to relevant function definitions?
sources <- c("initial.R", "test.R")

# save sources and packages as a 'context'
# Running the below, creates the 'contexts' dir on network share
ctx <- context::context_save(
    root = root,
    packages = packages,
    package_sources = context::package_sources(github =
        c("jackolney/CascadeDashboard", "jackolney/cascade")
    ),
    sources = sources
)

# Start logging (so we can see what is going on)
context::context_log_start()

# build a queue
obj <- didewin::queue_didewin(ctx)

# check network sync
obj$sync_files()

# RUN FUNCTIONS
# add to queue
t <- obj$enqueue(GetMasterDataSet("Kenya"))

# wait...
t$wait(2)

# check result
t$result()

# get task status
t$status()

# check how long things took
t$times()

# view log
t$log()

# view 'dide' logging info
obj$dide_log(t)

# TEST CALIBRATION
# add to queue
test <- obj$enqueue(test_calibration())

# get task status
test$status()

# check result
test$result()

# check how long things took
test$times()

# view log
test$log()

