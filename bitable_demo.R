library(config)
library(tidyverse)
library(httr)
library(jsonlite)
conf <- config::get()

## obtain tenant access token ----

get_tenant_token <- "/auth/v3/tenant_access_token/internal"
get_tenant_token_url <- with(conf, str_glue(domain, get_tenant_token))

tenant_access_token <-
    POST(
        get_tenant_token_url,
        body = list(
            app_id = conf$app_id,
            app_secret = conf$app_secret
        ),
        encode = "json",
        verbose()
    ) |>
    content() |> 
    pluck("tenant_access_token")

# form request headers 
headers <- add_headers(
    Authorization = str_glue("Bearer {tenant_access_token}")
)

## get record ids ----

get_records <- "/bitable/v1/apps/{app_token}/tables/{table}/records"
get_records_url <- with(conf, str_glue(domain, get_records))
resp <- GET(get_records_url, headers, verbose())

records <- resp |>
    content() |>
    pluck("data", "items") |>
    map(pluck, "record_id")
records

## delete all records ----

delete_records <- "/bitable/v1/apps/{app_token}/tables/{table}/records/batch_delete"
delete_records_url <- with(conf, str_glue(domain, delete_records))

r <- POST(
    delete_records_url,
    headers,
    body = list(records = records),
    encode = "json",
    verbose()
)

## making new records ----

batch_create <- "/bitable/v1/apps/{app_token}/tables/{table}/records/batch_create"
batch_create_url <- with(conf, str_glue(domain, batch_update))

samples <- df |>
    # sample_n(size = 5) |>
    pmap(function(...) list(...)) |>
    map(function(x) list(fields = x))

r <- POST(
    batch_create_url,
    headers,
    body = list(records = samples),
    encode = "json",
    verbose()
)
# end