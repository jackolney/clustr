ProjectionPlots <- function(wd, countryName) {

    # create output directly
    out_dir <- paste0(wd,"/results/", tolower(countryName), "/proj/")
    system(paste0("mkdir -p ", out_dir))

    # figure font set
    figFont <<- "Avenir Next"

    AdvCalib <<- data.frame(NatMort = 0.005, HIVMort = 1)

    # CareCascade Plot
    graphics.off(); quartz.options(w = 10, h = 4)
    fig1 <- GenCascadePlot_Thesis()
    print(fig1)
    quartz.save(file = paste0(out_dir, "cascade-projection.pdf"), type = "pdf")

    # 90-90-90 Plot
    graphics.off(); quartz.options(w = 9, h = 4)
    fig2 <- Gen909090Plot_Thesis()
    print(fig2)
    quartz.save(file = paste0(out_dir, "90-90-90.pdf"), type = "pdf")

    # Powers Plot
    graphics.off(); quartz.options(w = 15, h = 4)
    fig3 <- GenPowersCascadePlot_Thesis()
    print(fig3)
    quartz.save(file = paste0(out_dir, "cascade-powers.pdf"), type = "pdf")

    # New Infections
    graphics.off(); quartz.options(w = 6, h = 4)
    fig4 <- GenNewInfPlot_Thesis()
    print(fig4)
    quartz.save(file = paste0(out_dir, "new-infections.pdf"), type = "pdf")

    # AIDS Deaths
    graphics.off(); quartz.options(w = 6, h = 4)
    fig5 <- GenAidsDeathsPlot_Thesis()
    print(fig5)
    quartz.save(file = paste0(out_dir, "AIDS-deaths.pdf"), type = "pdf")

    # Discrete Cascade
    graphics.off(); quartz.options(w = 10, h = 4)
    fig6 <- GenDiscreteCascade_Thesis()
    print(fig6)
    quartz.save(file = paste0(out_dir, "cascade-discrete.pdf"), type = "pdf")

}
