#!/usr/bin/env Rscript --vanilla

library(tidyverse)
library(config)
library(httr)
library(jsonlite)
source("generate_fake_data.R")
source("query_bitable_api.R")
conf <- config::get()

while (1) {

    # read from file if exists 
    if (file.exists(conf$cachefile)) {
        tenant_access_token <- readLines(conf$cachefile)
    } else {
        tenant_access_token <- get_tenant_token(conf)
        write(tenant_access_token, conf$cachefile, append = FALSE)
    }
    headers  <- form_request_headers(tenant_access_token)    
    fakedata <- generate_fake_data()
    resp     <- batch_create_records(conf, headers, fakedata)

    if (content(resp)$msg == "success") {
        msg <- stringr::str_glue("Insert {length(fakedata)} records\t")
        message(msg, "@ ", Sys.time())
    } else {
        message("Error. Check status.")
        stop()
    }
    Sys.sleep(conf$interval) # pause for abit
}