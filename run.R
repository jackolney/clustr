################################################################################

# Project Plan

# >> We should be aiming to do the easy stuff locally and then pass the hard stuff to the cluster
# >> Then return a whole bunch of objects
# >> write new version of RunNSCalibration() function for example
# >> return a LIST of the objects that it creates globally
# >> then we can access and manipulate them later
# >> implement slackr or something to notify me of jobs finishing
# >> then we can do all the quartz plotting and table shit locally

################################################################################
# dide-tools didewin setup
# demo workflow

# source master functions
source("~/git/clustr/setup.R")

# if at home, connect to the vpn
'vpn-connect'
'vpn-disconnect'

# mount / login to cluster
login()


setwd("~/git/CascadeDashboard/inst/app")

MasterName <- "Zimbabwe"
MasterData <- GetMasterDataSet(MasterName)

# ---- #
set.seed(100)
# ---- #

MaxError <- 2
MinNumber <- 100

# Define Parameter Range
# function can now be edited
# e.g. DefineParmRange(p = c(0, 1))
# parRange <- DefineParmRange()

# parRange <- DefineParmRange(p = c(0.86, 1), omega = c(0, 0.01))
parRange <- DefineParmRange(p = c(0.7, 1), omega = c(0, 0.01))

# Run Calibration
t <- obj$enqueue(
    RunClusterCalibration(
        country = MasterName,
        data = MasterData,
        maxIterations = 1e4,
        maxError = MaxError,
        limit = MinNumber,
        parRange = parRange,
        targetIterations = 1e5)
)

t$wait(10)

out <- t$result()

t$log()

hist(out$runError)

t$status()
t$times()
# obj$sync_files()

# dismount / logout of cluster
logout()




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

################################################################################
# Thoughts on how to improve this

# Either, I go 'full cluster' in other words, I push a master file to the cluster
# And this spawns all the countries and simulations that I want, sets things up
# submits the jobs to the cluster, and saves the final image.

# - Generating plots on the cluster is not advisable as we get all screwy with
# font libraries and other shit from Windows.

# The alternative is to run these entirely locally but then farm out the hard
# stuff to the cluster.

# The disadvantage of this is the it makes everything a bit single-threaded.

# Perhaps I can find a middle ground whereby I can farm out the hard stuff to
# the cluster in one go...

# 1. Calibration
# 2. Projection
# 3. Optimisation

# So, three big loops that go over all countries etc.

# Need a map that links cluster jobs to actual names

obj$tasks_list()

# This looks like a MASSIVE list of ALLL jobs.

# Can I clear this out?

obj$id()

test <- obj$task_get("bb98ae62682344c9aea754f355b52513")

head(test$result())

sizes <- 3:8
grp <- queuer::qlapply(sizes, make_tree, obj, timeout=0)
