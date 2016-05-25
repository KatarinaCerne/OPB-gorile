library(shiny)
library(dplyr)
library(RPostgreSQL)

source("auth.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.postopek <- tbl(conn, "postopek")
  tbl.preiskava <- tbl(conn, "preiskava")
  tbl.lokacija <- tbl(conn, "lokacija")
  tbl.lsoa <- tbl(conn, "lsoa")
  
  output$osebe <- renderTable({
    t <- tbl.zlocin %>% data.frame()
    t
  })
  
})

