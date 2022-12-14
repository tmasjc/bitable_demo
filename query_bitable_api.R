require(httr)

get_tenant_token <- function(conf) {
    addr <- "/auth/v3/tenant_access_token/internal"
    get_tenant_token_url <- stringr::str_glue(conf$domain, addr)

    r <- POST(
        get_tenant_token_url,
        body = list(
            app_id = conf$app_id,
            app_secret = conf$app_secret
        ),
        encode = "json"
    ) 
    # return 
    if (httr::status_code(r) == 200) {
        purrr::pluck(content(r), "tenant_access_token")
    } else {
        stop("Invalid status. Check tenant access token.")
    }
}

form_request_headers <- function(token) {
    add_headers(
        Authorization = stringr::str_glue("Bearer {token}")
    )
}

get_record_ids <- function(conf, headers) {
    addr <- "{domain}/bitable/v1/apps/{app_token}/tables/{table}/records"
    get_records_url <- with(conf, stringr::str_glue(addr))
    resp <- GET(get_records_url, headers)

    resp |>
        content() |>
        purrr::pluck("data", "items") |> # nolint
        purrr::map(pluck, "record_id")
}

delete_records <- function(conf, headers, records) {
    addr <- "{domain}/bitable/v1/apps/{app_token}/tables/{table}/records/batch_delete"
    delete_records_url <- with(conf, stringr::str_glue(addr))

    POST(
        delete_records_url,
        headers,
        body = list(records = records),
        encode = "json"
    )
}

batch_create_records <- function(conf, headers, data) {
    addr <- "{domain}/bitable/v1/apps/{app_token}/tables/{table}/records/batch_create"
    batch_create_url <- with(conf, stringr::str_glue(addr))

    POST(
        batch_create_url,
        headers,
        body = list(records = data),
        encode = "json",
        # verbose(),
        handle = NULL
    )
}
