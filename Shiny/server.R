library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
library(ggmap)

source("auth.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.postopek <- tbl(conn, "postopek")
  tbl.preiskava <- tbl(conn, "preiskava")
  #tbl.lokacija <- tbl(conn, "lokacija") tole zakomentiramo, ni v bazi
  zbl.lsoa <- tbl(conn, "lsoa")
  
  
  output$zlocini <- renderTable({
    t <- tbl.zlocin %>% data.frame()
    t
  })
  
  
  output$postopki <- renderTable(
    {
      t1 <- tbl.postopek %>% data.frame()
      t1
    }
  )
  output$postopkiPita <- renderPlot({
  plotData <- tbl.zlocin %>% select(status) %>% data.frame() %>% table()
  oznake <- paste(names(plotData), "\n", plotData, sep="")
  pie3D(plotData, labels = oznake, explode = 0.1, main = "Zlocini")
  #barp(plotData,width=0.4,names.arg=oznake,legend.lab=NULL,legend.pos=NULL,
  #     col=NULL,border=par("fg"),main="zlocini",xlab="",ylab="",xlim=NULL,ylim=NULL,
  #     x=NULL,staxx=FALSE,staxy=FALSE, height.at=NULL,height.lab=NULL,
  #     cex.axis=par("cex.axis"),pch=NULL,cylindrical=FALSE,shadow=FALSE,
  #     do.first=NULL,ylog=FALSE,srt=NA)
  #  })
 
  })
  
  
  # Zemljevid, trenutno samo za City od London
  output$map <- renderPlot({
    crimes <- tbl.zlocin %>% data.frame()
    zemljevid <- qmap('City of London', zoom = 14, maptype = 'hybrid')
    zemljevid + geom_point(data = crimes, aes(x = gsirina, y = gdolzina), color="red", size=2, alpha=0.5)
  })
  
  
})
