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



