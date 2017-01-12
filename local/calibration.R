PushClusterCalibration <- function(countryName, MaxError, MinNumber) {
    # setup
    MasterData <- GetMasterDataSet(countryName)
    parRange <- DefineParmRange(p = c(0.7, 1), omega = c(0, 0.01))

    # pass to cluster
    t <- obj$enqueue(
        RunClusterCalibration(
            country = countryName,
            data = MasterData,
            maxIterations = 1e4,
            maxError = MaxError,
            limit = MinNumber,
            parRange = parRange,
            targetIterations = 1e5)
    )

    # print task_id
    message(paste("task_id:", t$id))

    # return t
    return(t)
}

CalibrationPlots <- function(wd, countryName) {
    # create output directly
    out_dir <- paste0(wd,"/results/", tolower(countryName), "/cal/")
    system(paste0("mkdir -p ", out_dir))

    # figure font set
    figFont <<- "Avenir Next"

    # Cascade in 2015
    graphics.off(); quartz.options(w = 10, h = 4)
    fig1 <- BuildCalibPlot_Thesis(data = CalibOut,
        originalData = MasterData,
        limit = MinNumber)
    print(fig1)
    quartz.save(file = paste0(out_dir, "cascade-2015.pdf"), type = "pdf")

    # Error Histogram
    graphics.off(); quartz.options(w = 6, h = 3)
    fig2 <- BuildCalibrationHistogram_Thesis(
        runError = runError,
        maxError = 0.06)
    print(fig2)
    quartz.save(file = paste0(out_dir, "calib-hist.pdf"), type = "pdf")

    # Calibration Detail
    graphics.off(); quartz.options(w = 10, h = 8)
    fig3 <- BuildCalibDetailPlot_Thesis(
        data = CalibOut,
        originalData = MasterData,
        limit = MinNumber)
    print(fig3)
    quartz.save(file = paste0(out_dir, "calib-detail.pdf"), type = "pdf")

    # Parameter Histograms
    graphics.off(); quartz.options(w = 10, h = 4)
    fig4 <- BuildCalibrationParameterHistGroup_Thesis()
    print(fig4)
    quartz.save(file = paste0(out_dir, "par-hist.pdf"), type = "pdf")

    # DataReviewPlot
    graphics.off(); quartz.options(w = 10, h = 4)
    fig5 <- BuildDataReviewPlot_Thesis(data = MasterData$calib)
    print(fig5)
    quartz.save(file = paste0(out_dir, "calib-data.pdf"), type = "pdf")

    # Parameter values
    a <- paste0(round(Quantile_95(CalibParamOut[["rho"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["rho"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["rho"]])[["upper"]], 4),
        "]")
    b <- paste0(round(Quantile_95(CalibParamOut[["q"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["q"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["q"]])[["upper"]], 4),
        "]")
    c <- paste0(round(Quantile_95(CalibParamOut[["epsilon"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["epsilon"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["epsilon"]])[["upper"]], 4),
        "]")
    d <- paste0(round(Quantile_95(CalibParamOut[["kappa"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["kappa"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["kappa"]])[["upper"]], 4),
        "]")
    e <- paste0(round(Quantile_95(CalibParamOut[["gamma"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["gamma"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["gamma"]])[["upper"]], 4),
        "]")
    f <- paste0(round(Quantile_95(CalibParamOut[["theta"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["theta"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["theta"]])[["upper"]], 4),
        "]")
    g <- paste0(round(Quantile_95(CalibParamOut[["p"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["p"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["p"]])[["upper"]], 4),
        "]")
    h <- paste0(round(Quantile_95(CalibParamOut[["omega"]])[["mean"]], 4),
        " [",
            round(Quantile_95(CalibParamOut[["omega"]])[["lower"]], 4),
        " to ",
            round(Quantile_95(CalibParamOut[["omega"]])[["upper"]], 4),
        "]")

    tabl <- list(a,b,c,d,e,f,g,h)
    names(tabl) <- c("rho", "q", "epsilon", "kappa", "gamma", "theta", "p", "omega")
    return(tabl)
}
