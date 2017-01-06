RunClusterCalibration <- function(country, data, maxIterations, maxError, limit, parRange, targetIterations = 1e4) {
    # limit = 100
    # maxIterations = 1e4
    # maxError = 2

    # Set Global Variables
    time <- seq(0, 5, 1)
    p <- parameters(
        prop_preART_500    = data[["cd4"]][1,"prop.Off.ART.500"][[1]],
        prop_preART_350500 = data[["cd4"]][1,"prop.Off.ART.350500"][[1]],
        prop_preART_250350 = data[["cd4"]][1,"prop.Off.ART.250350"][[1]],
        prop_preART_200250 = data[["cd4"]][1,"prop.Off.ART.200250"][[1]],
        prop_preART_100200 = data[["cd4"]][1,"prop.Off.ART.100200"][[1]],
        prop_preART_50100  = data[["cd4"]][1,"prop.Off.ART.50100"][[1]],
        prop_preART_50     = data[["cd4"]][1,"prop.Off.ART.50"][[1]],
        t_1 = ConvertYear(data[["treatment_guidelines"]][["more500"]]),
        t_2 = ConvertYear(data[["treatment_guidelines"]][["less500"]]),
        t_3 = ConvertYear(data[["treatment_guidelines"]][["less350"]]),
        t_4 = ConvertYear(data[["treatment_guidelines"]][["less250"]]),
        t_5 = ConvertYear(data[["treatment_guidelines"]][["less200"]])
    )

    ## Sample Parameters
    # Defines max / min
    # Allows user to override these
    # Uses LHS to sample parameter space
    message("Defining parameter space")
    lhs <- FME::Latinhyper(parRange, num = targetIterations)

    ## Sample Initial Compartment Values
    # Define max / min (also accounts for missing data)
    # Uses LHS to sample parameter space
    # Fishes out only sensical data
    # Deletes previous data.frame


    # While loop setup, ensures we get 10k iterations to trial.
    # Can always be extended to KEEP GOING endlessly
    initRange <- DefineInitRange(data = data, min = 0.5, max = 1.5)
    its <- 0L
    lhsInitial_Out <- matrix()

    while (its < targetIterations) {
        lhsInitial <- FME::Latinhyper(initRange, num = maxIterations * 5)
        lhsInitial_Sense <- FindSense(samples = lhsInitial)
        if (is.na(lhsInitial_Out[[1]])) {
            lhsInitial_Out <- lhsInitial_Sense
        } else {
            lhsInitial_Out <- rbind(lhsInitial_Out, lhsInitial_Sense)
        }
        its <- dim(lhsInitial_Out)[1]
    }

    # Garbage collection
    rm(lhsInitial)
    rm(lhsInitial_Sense)

    ## Sample Incidence
    # Define max / min (from Spectrum Uncertainty Analysis)
    # Uses LHS to sample parameter space
    incRange <- DefineIncidenceRange(incidenceData = data$incidence)
    lhsIncidence <- FME::Latinhyper(incRange, num = targetIterations)

    ## For each draw, update parameter vector (p), run model, calculate error and store it.
    # Initial Calibration
    message("Running simulations")
    # pb <- txtProgressBar(min = 0, max = limit, style = 1)
    v <- 0
    selectedRuns <<- c()
    minError <<- 1e6
    minErrorRun <<- NULL
    runError <<- c()
    CalibOut <<- c()
    for (k in 1:dim(lhsInitial_Out)[1]) {

        p[["Rho"]]     <- lhs[,"rho"][k]
        p[["Epsilon"]] <- lhs[,"epsilon"][k]
        p[["Kappa"]]   <- lhs[,"kappa"][k]
        p[["Gamma"]]   <- lhs[,"gamma"][k]
        p[["Theta"]]   <- lhs[,"theta"][k]
        p[["Omega"]]   <- lhs[,"omega"][k]
        p[["p"]]       <- lhs[,"p"][k]
        p[["q"]]       <- lhs[,"q"][k]

        i <- incidence(as.double(lhsIncidence[k,]))
        y <- GetCalibInitial(p, data, init2010 = lhsInitial_Out[k,])
        iOut <- SSE(AssembleComparisonDataFrame(country = country, model = CallCalibModel(time, y, p, i), data = data))
        runError[k] <<- sum(iOut[iOut$source == "error", "value"])

        # If error <= maxError then store value of k
        if (runError[k] <= maxError & v < limit) {
            v <- v + 1
            if (runError[k] < minError) {
                minError <<- runError[k]
                minErrorRun <<- v
            }
            selectedRuns[v] <<- k
            CalibOut <<- rbind(CalibOut, iOut)
            message(paste(paste0(round((v / limit) * 100, digits = 0), "%"), "of", paste0(round((k / dim(lhsInitial_Out)[1]) * 100, digits = 0), "%")))
            # setTxtProgressBar(pb, v)
            if (v == limit) break;
        }
        if (k == dim(lhsInitial_Out)[1]) warning("Hit iteration wall.")
    }

    # Global Data Frames for Parameters / Initial Values
    CalibParamOut <<- FillParValues(samples = lhs,             positions = selectedRuns, limit = limit)
    CalibInitOut  <<- FillInitValues(samples = lhsInitial_Out, positions = selectedRuns, limit = limit)
    CalibIncOut   <<- FillIncValue(samples = lhsIncidence,     positions = selectedRuns, limit = limit)

    # Calculate min and max values used by parameter set (deprecated now?)
    ParamMaxMin <<- data.frame(
        min = apply(CalibParamOut, 2, min),
        max = apply(CalibParamOut, 2, max)
    )
    message(paste("\nminErrorRun =", minErrorRun))

    out <- list(
        CalibIncOut   = CalibIncOut,
        CalibInitOut  = CalibInitOut,
        CalibOut      = CalibOut,
        CalibParamOut = CalibParamOut,
        minError      = minError,
        minErrorRun   = minErrorRun,
        ParamMaxMin   = ParamMaxMin,
        runError      = runError,
        selectedRuns  = selectedRuns
    )
    out
}
