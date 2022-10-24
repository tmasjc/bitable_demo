## generate fake data ----

# helper function to generate data
gen_ <- function(opts, prob = "", length = 500) {
    n <- length(opts)
    p <- if (all(prob == "")) rep(1 / n, n) else prob
    sample(
        x = opts,
        size = length,
        replace = TRUE,
        prob = p
    )
}

# parameters for fake data
params <- list(
    N   = 500,
    sex = c("Male", "Female"),
    src = c("Facebook Ads", "Google SEM", "Inbound Marketing")
)

# this is our fake data
df <-
    tibble(
        ID     = 1:params$N,
        Sex    = gen_(params$sex, c(0.6, 0.4)),
        Date   = gen_(seq(Sys.Date() - 3, Sys.Date(), by = 1)),
        Source = gen_(params$src, c(0.2, 0.2, 0.2)),
        CAC    = rnorm(n = params$N, mean = 150, sd = 20)
    )
