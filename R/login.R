#' Login to DIDE cluster
#'
#' @param username DIDE username
#'
#' @param remotewd remote directory on network share (don't require entire path)
#'
#' @param sources vector of required sources
#'
#' @param packages vector of required packages. Just state the name of packages to be sourced from
#' CRAN, while for packages from GitHub state the username and package e.g. 'hadley/ggplot2'
#'
#' @param cluster either "MRC" or "DIDE"
#'
#' @param log boolean to set logging
#'
#' @export
login <- function(username = "jjo11",
                  remotewd = "clustr",
                  sources = NULL,
                  packages = c("jackolney/cascade", "jackolney/CascadeDashboard", "devtools"),
                  cluster = "MRC",
                  log = TRUE) {

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
    clustr::mount(username, remotewd)

    # configure correct cluster
    if (cluster == "MRC") {
        cluster <- "fi--didemrchnb"
    } else if (cluster == "DIDE") {
        cluster <- "fi--dideclusthn"
    } else {
        warning("Cluster name not recognised, defaulting to DIDE cluster")
        cluster <- "fi--dideclusthn"
    }

    # global config
    # perhaps include a check for presence of '~/.smbcredentials'
    if (file.exists("~/.smbcredentials")) {
        didewin::didewin_config_global(credentials = "~/.smbcredentials",
                                   cluster = cluster,
                                   workdir = file.path("/tmp", username, remotewd))
    } else {
        didewin::didewin_config_global(cluster = cluster, workdir = file.path("/tmp", username,
           remotewd))
    }

    # test login (spawns XQuartz login window) - alternative?
    message("Attempting web login, password required...")
    didewin::web_login()

    # create a root (this should make a root dir 'contexts')
    root <- file.path("/tmp", username, remotewd, "contexts")

    # save sources and packages as a 'context'
    # Running the below, creates the 'contexts' dir on network share
    # package_sources is for custom packages
    # now check for package location based upon presence of '/'
    # package_names contains only names (all after '/')
    slash <- "/"
    github_packages <- packages[which(grepl(slash, packages))]
    package_names <- c(packages[which(!grepl(slash, packages))],
        gsub(pattern = ".*/", replacement = "", x = github_packages))

    message("Context setting up remote network share...")
    ctx <- context::context_save(
        root = root,
        packages = package_names,
        package_sources = context::package_sources(github = github_packages),
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
