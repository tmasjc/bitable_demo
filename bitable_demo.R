library(config)
library(tidyverse)
library(httr)
library(jsonlite)
conf <- config::get()

# request headers 
headers <- add_headers(
    Authorization = "Bearer t-g104aoacADU6I74IXXNOXCEYNT777PFVJ3MAGNDU"
)

## generate fake data ----

# helper function to generate data
gen_ <- function(opts, prob = "", n = 500) {
    n <- length(opts)
    p <- if (all(prob == "")) rep(1 / n, n) else prob
    sample(
        x = opts,
        size = N,
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

## obtain app token ----

get_access_token <- "/open-apis/auth/v3/app_access_token/internal"
get_access_token_url <- with(conf, str_glue(domain, get_access_token))

app_access_token <-
    POST(
        get_access_token_url,
        body = list(
            app_id = conf$app_id,
            app_secret = conf$app_secret
        ),
        encode = "json",
        verbose()
    ) |>
    content() |>
    pluck("app_access_token")

## obtain one-time code ----

get_code <- "/open-apis/authen/v1/index?redirect_uri={redirect_uri}&app_id={app_id}"
redirect_uri <- URLencode(conf$domain, reserved = TRUE)
get_code_url <- with(conf, str_glue(domain, get_code))
resp <- GET(get_code_url)
content(resp)

## obtain user access token ----

get_user_token <- "/open-apis/authen/v1/access_token"
get_user_token_url <- with(conf, str_glue(domain, get_user_token))

POST(
    get_user_token_url,
    body = list(
        grant_type:"authorization_code",
        code:""
    )
)

## get record ids ----

get_records <- "records?page_size={pagesize}"

get_records_url <- with(conf, str_glue(domain, api, get_records))

resp <- GET(get_records_url, headers, verbose())

records <- resp |>
    content() |>
    pluck("data", "items") |>
    map(pluck, "record_id")
records

## making new records ----

batch_update <- "/bitable/v1/apps/{app_token}/tables/{table}/records/batch_create"
batch_update_url <- with(conf, str_glue(domain, batch_update))

samples <- df |>
    sample_n(size = 5) |>
    pmap(function(...) list(...)) |>
    map(function(x) list(fields = x))

r <- POST(
    batch_update_url,
    headers,
    body = list(records = samples),
    encode = "json",
    verbose()
)

