# Script to source all non-shiny components of the model
source(system.file("app/server/calibration/assumptions.R",          package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/calibration-data.R",     package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/calibration.R",          package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/error.R",                package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/initial.R",              package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/marrakech-data.R",       package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/master.R",               package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/misc-functions.R",       package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/model.R",                package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/calibration/plot-functions.R",       package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/country/misc-functions.R",           package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/misc-functions.R",                   package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/misc-functions.R",                   package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/baseline-model.R",             package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/best-fit-model.R",             package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/beta.R",                       package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/initial.R",                    package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/parameters.R",                 package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/sim-abs.R",                    package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/model/sim-prop.R",                   package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/non-shiny/non-shiny-calibration.R",  package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/non-shiny/non-shiny-optimisation.R", package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/non-shiny/thesis/thesis-figures.R",  package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/optimisation/frontier.R",            package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/optimisation/input-functions.R",     package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/optimisation/output-functions.R",    package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/optimisation/parameters.R",          package = "CascadeDashboard"), local = FALSE)
source(system.file("app/server/optimisation/plot-functions.R",      package = "CascadeDashboard"), local = FALSE)

AdjustHIVTestCost <- function() {
    if (reactiveAdjustCost$switch == TRUE) {
        message("AdjustCost == TRUE")
        if (exists("CalibOut")) {
            if (exists("MasterData")) {
                if (!is.na(MasterData$pop$value)) {
                    # pop value is not NA

                    # From calibration (CalibOut), calculate mean # 'PLHIV' in 2015
                    meanPLHIV <- mean(CalibOut[CalibOut$indicator == "PLHIV" & CalibOut$year == 2015 & CalibOut$source == "model", "value"])
                    # From calibration (CalibOut), calculate mean # 'PLHIV in Care' in 2015
                    meanCARE <- mean(CalibOut[CalibOut$indicator == "PLHIV in Care" & CalibOut$year == 2015 & CalibOut$source == "model", "value"])
                    # Calculate those persons Not In Care
                    NotInCare <- meanPLHIV - meanCARE
                    # Calculate the HIV-negative population size
                    Negative <- MasterData$pop$value - meanPLHIV

                    # Jeff's assumption
                    # HIV-negative persons are 0.75 times as likely to test as HIV-positive in general population
                    # Lancet GH Cost-Effectiveness Paper (suppl info page 10)
                    jeff <- 0.65

                    # Using the assumption that persons are tested randomly
                    CostFactor <- ((jeff * Negative) + NotInCare) / NotInCare
                    # print(paste("CostFactor =", CostFactor))
                    # Another way of thinking about this is as the:
                    # probability of testing a positive individual
                    # given the size of the undiagnosed (not in care) population
                    # 1/(NotInCare / ((jeff * Negative) + NotInCare))

                    # CAREFUL
                    # print(paste("OLD reactiveCost$test =", reactiveCost$test))
                    reactiveCost$test <<- CostFactor * SafeReactiveCost$test
                    # print(paste("NEW reactiveCost$test =", reactiveCost$test))

                } else {
                    # pop value is NA
                    # DEFAULT of FIVE
                    CostFactor <- 5
                    # print("DEFAULT")
                    # print(paste("OLD reactiveCost$test =", reactiveCost$test))
                    reactiveCost$test <<- CostFactor * SafeReactiveCost$test
                    # print(paste("NEW reactiveCost$test =", reactiveCost$test))

                }

            } else {
                warning("MasterData does not exist")
            }
        } else {
            warning("CalibOut is does not exist")
        }
    } else {
        message("AdjustCost == FALSE")
    }
}

# editing MasterData functions
new_data <- function(country, year, indicator, value, weight, source) {
    if (!is.character(country))   stop("country is not a character.")
    if (!is.numeric(year))        stop("year is not a character.")
    if (!is.character(indicator)) stop("indicator is not a character.")
    if (!is.numeric(value))       stop("value is not a character.")
    if (!is.character(weight))    stop("weight is not a character.")
    if (!is.character(source))    stop("soruce is not a character.")
    # Check if valid indicator
    indicator_list <- c("PLHIV", "PLHIV Diagnosed", "PLHIV in Care", "PLHIV on ART", "PLHIV Suppressed")
    if (!any(indicator_list == indicator)) stop("Not a valid indicator type")
    new_dat <- data.frame(country, year, indicator, value, weight, source)
    new_dat
}

replace_or_append <- function(datOne, datTwo) {
    # find out if indicator for datTwo exists in datOne
    if (any(as.character(datOne[datOne$year == datTwo$year, "indicator"]) == as.character(datTwo$indicator))) {
        # REPLACE
        datOne[datOne$year == datTwo$year & datOne$indicator == as.character(datTwo$indicator), "value"]  <- as.numeric(datTwo$value)
        datOne[datOne$year == datTwo$year & datOne$indicator == as.character(datTwo$indicator), "weight"] <- as.character(datTwo$weight)
        datOne[datOne$year == datTwo$year & datOne$indicator == as.character(datTwo$indicator), "source"] <- as.character(datTwo$source)

    } else {
        # APPEND
        datOne <- rbind(datOne, datTwo)
    }
    datOne
}

message("Good to go...")
