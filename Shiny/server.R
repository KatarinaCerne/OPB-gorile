library(shiny)
library(dplyr)
library(RPostgreSQL)

source("auth.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "Zlocin")
  tbl.postopek <- tbl(conn, "Postopek")
  tbl.preiskava <- tbl(conn, "Preiskava")
  tbl.lokacija <- tbl(conn, "Lokacija")
  tbl.lsoa <- tbl(conn, "LSOA")
  
  output$zlocini <- renderTable({
    t <- tbl.zlocin %>% data.frame()
    t
  })
  
})

