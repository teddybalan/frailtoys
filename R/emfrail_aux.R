

# Auxiliary functions which create the parameters
dist_to_pars <- function(dist, logfrailtypar, pvfm) {

    if (dist == "gamma") {
        alpha <- bbeta <- exp(logfrailtypar)
        dist_id <- 0L
    }

    if (dist == "stable") {
        theta <- exp(logfrailtypar) + 1  # so theta >1
        bbeta <- 1 - 1/theta  # so bbeta in (0,1), that's what's important
        alpha <- theta / (theta - 1)  # alpha = 1/beta for scaling
        dist_id <- 1L
    }

    if (dist == "pvf") {
        alpha <- abs((pvfm + 1)/pvfm * exp(logfrailtypar))
        bbeta <- (pvfm + 1) * exp(logfrailtypar)
        dist_id <- 2L
    }

    list(alpha = alpha, bbeta = bbeta, dist = dist_id)
}





# this one gives the baseline cumulative hazard at all the time points;

getchz <- function(Y, newrisk, explp) {
    death <- (Y[, ncol(Y)] == 1)
    dtime <- Y[, ncol(Y) - 1]
    time <- sort(unique(dtime))

    # n events / tstop time point
    nevent <- as.vector(rowsum(1 * death, dtime))

    # sum of e^beta x per time point -- e de fapt risk?
    nrisk <- rev(cumsum(rev(rowsum(explp, dtime))))

    # smaller than time intervals
    delta <- min(diff(time))/2
    etime <- c(sort(unique(Y[, 1])), max(Y[, 1]) + delta)  #unique entry times

    # this is to interpolate at tstop unique points.
    indx <- approx(etime, 1:length(etime), time, method = "constant", rule = 2, f = 1)$y

    esum <- rev(cumsum(rev(rowsum(explp, Y[, 1]))))  #not yet entered
    nrisk <- nrisk - c(esum, 0)[indx]

    haz <- nevent/nrisk
    cumhaz <- cumsum(haz)

    chz2 <- cumhaz * newrisk

    tev = time[haz > 0]
    haz_ret = haz * newrisk

    haz_tev = haz_ret[haz_ret > 0]


    list(time = time, cumhaz = chz2, haz = haz_ret, tev = tev, haz_tev = haz_tev)


}

