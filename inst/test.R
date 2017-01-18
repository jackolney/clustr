# Test Calibration Script

test_calibration <- function() {
    MasterName <- "Zimbabwe"
    MasterData <- GetMasterDataSet(MasterName)

    # ---- #
    set.seed(100)
    # ---- #

    MaxError <- 2
    MinNumber <- 1000

    # Define Parameter Range
    # function can now be edited
    # e.g. DefineParmRange(p = c(0, 1))
    # parRange <- DefineParmRange()

    # parRange <- DefineParmRange(p = c(0.86, 1), omega = c(0, 0.01))
    parRange <- DefineParmRange(p = c(0.7, 1), omega = c(0, 0.01))

    # Run Calibration
    RunNSCalibration(
        country = MasterName,
        data = MasterData,
        maxIterations = 1e4,
        maxError = MaxError,
        limit = MinNumber,
        parRange = parRange,
        targetIterations = 1e5)

    CalibOut
}
