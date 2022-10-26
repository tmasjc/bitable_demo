generate_fake_data <- function(min = 1, max = 10) {

    # helper function to generate data
    gen_ <- function(opts, prob = "", length = max) {
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
        sex = c("Male", "Female"),
        src = c("Facebook Ads", "Google SEM", "Inbound Marketing")
    )

    # this is our fake data
    tibble::tibble(
        ID     = ids::random_id(max),
        Sex    = gen_(params$sex, c(0.3, 0.7)),
        Date   = gen_(seq(Sys.Date() - 3, Sys.Date(), by = 1)),
        Source = gen_(params$src, c(0.2, 0.2, 0.2)),
        CAC    = rnorm(n = max, mean = 150, sd = 50)
    ) |>
        dplyr::sample_n(round(runif(1, min = min, max = max))) |>
        # convert to JSON convenient
        purrr::pmap(function(...) list(...)) |>
        purrr::map(function(x) list(fields = x))
}
