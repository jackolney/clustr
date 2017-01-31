#' Login to DIDE cluster
#'
#' @param cwd set current working directory
#'
#' @param remotewd remote directory on network share
#'
#' @param cluster select cluster 'fi--didemrchnb' or 'fi--dideclusthn'
#'
#' @param log boolean to set logging
#'
#' @export
login <- function(cwd = "~/git/clustr",
                  remotewd = "/tmp/jjo11/clustr",
                  cluster = "fi--didemrchnb",
                  log = TRUE) {

    # define a working directory
    setwd(cwd)

    # Try loading packages, else install
    message("Loading packages...")
    if (!require("context")) devtools::install_github("dide-tools/context")
    if (!require("didewin")) devtools::install_github("dide-tools/didewin")
    if (!require("ids"))     devtools::install_github("richfitz/ids")
    if (!require("queuer"))  devtools::install_github("richfitz/queuer")
    if (!require("syncr")) {
        install.packages("syncr",
            repos = c(
                CRAN = "https://cran.rstudio.com",
                drat = "https://richfitz.github.io/drat"
            )
        )
    }

    # mount network share
    mount()

    # global config
    # perhaps include a check for presence of '~/.smbcredentials'
    if (file.exists("~/.smbcredentials")) {
        didewin::didewin_config_global(credentials = "~/.smbcredentials",
                                   cluster = cluster,
                                   workdir = remotewd)
    } else {
        didewin::didewin_config_global(cluster = cluster, workdir = remotewd)
    }

    # test login (spawns XQuartz login window) - alternative?
    message("Attempting web login, password required...")
    didewin::web_login()

    # create a root (this should make a root dir 'contexts')
    root <- file.path(remotewd, "contexts")

    # name the package I need
    packages <- c("cascade", "CascadeDashboard", "devtools")

    # containing function definitions (bit hacky but okay)
    # sources <- c(
    #     "inst/initial.R",
    #     "inst/test.R",
    #     "R/calibration.R",
    #     "R/projection.R",
    #     "R/optimisation.R"
    # )
    sources <- NULL

    # save sources and packages as a 'context'
    # Running the below, creates the 'contexts' dir on network share
    # package_sources is for custom packages
    message("Context setting up remote network share...")
    ctx <- context::context_save(
        root = root,
        packages = packages,
        package_sources = context::package_sources(
            github = c("jackolney/CascadeDashboard@zimbabwe", "jackolney/cascade")
        ),
        sources = sources
    )

    # log log log
    if (log) context::context_log_start()

    # build a queue (global)
    message("Building queue...")
    obj <- didewin::queue_didewin(ctx)

    # check network sync
    message("Syncing")
    obj$sync_files()

    message("Complete")
    obj
}
