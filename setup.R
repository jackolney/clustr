# dide-tools didewin setup

## setup definition
# function sets up everything automatically
login <- function(cwd = "~/git/clustr",
                  remotewd = "/tmp/jjo11/clustr",
                  cluster = "fi--didemrchnb",
                  log = TRUE) {

    # define a working directory
    setwd(cwd)

    # Try loading packages, else install
    message("Loading packages...")
    if (!require("context")) devtools::install_github("dide-tools/ids")
    if (!require("didewin")) devtools::install_github("dide-tools/ids")
    if (!require("ids"))     devtools::install_github("richfitz/ids")
    if (!require("queuer"))  devtools::install_github("richfitz/ids")
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
    didewin::didewin_config_global(credentials = "jjo11",
                                   cluster = "fi--didemrchnb",
                                   workdir = remotewd)

    # test login (spawns XQuartz login window) - alternative?
    message("Attempting web login, password required...")
    didewin::web_login()

    # create a root (this should make a root dir 'contexts')
    root <- file.path(remotewd, "contexts")

    # name the package I need
    packages <- c("cascade", "CascadeDashboard", "devtools")

    # containing function definitions (bit hacky but okay)
    sources <- c("initial.R", "test.R")

    # save sources and packages as a 'context'
    # Running the below, creates the 'contexts' dir on network share
    # package_sources is for custom packages
    ctx <- context::context_save(
        root = root,
        packages = packages,
        package_sources = context::package_sources(
            github = c("jackolney/CascadeDashboard", "jackolney/cascade")
        ),
        sources = sources
    )

    # log log log
    if (log) context::context_log_start()

    # build a queue (global)
    message("Building queue...")
    obj <<- didewin::queue_didewin(ctx)

    # check network sync
    message("Syncing")
    obj$sync_files()

    message("Complete")
}

# mount network share in tmp directory
mount <- function() {
    system("mkdir -p /tmp/jjo11")
    if (!dir.exists("/tmp/jjo11/clustr")) {
        system("mount -t smbfs //jjo11@fi--san02.dide.ic.ac.uk/homes/jjo11 /tmp/jjo11")
    }
}

# umount network share
logout <- function() {
    system("umount /tmp/jjo11")
}
