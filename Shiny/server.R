library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
library(ggmap)

source("auth.R")

shinyServer(function(input, output, clientData, session) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.postopek <- tbl(conn, "postopek")
  tbl.preiskava <- tbl(conn, "preiskava")
  #tbl.lokacija <- tbl(conn, "lokacija") tole zakomentiramo, ni v bazi
  zbl.lsoa <- tbl(conn, "lsoa")
  ttt <- tbl.zlocin %>% select(status) %>% group_by(status)%>%data.frame()
  
  
  output$zlocini <- renderTable({
    t <- tbl.zlocin %>% select(status) %>% group_by(status) %>% summarise(stevilo=n())%>% select(stevilo)%>%data.frame()
    #t2<-unlist(t)%>%table()
    #
  })

  
  output$postopki <- renderTable({
      t1 <- tbl.postopek %>% data.frame()
      t1
  })
  
  
  output$postopkiPita <- renderPlot({
    plotData <- tbl.zlocin %>% group_by(status) %>%
      summarise(count = count(status)) %>% data.frame()
    ggplot(plotData, aes(x = factor(1), y = count, fill = status)) +
      geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") +
      xlab("") + ylab("")
    #plotData <- tbl.zlocin %>% select(status) %>% group_by(status)
    #oznake <- paste(names(plotData), "\n", plotData, sep="")
    #delezi <- 
    #t2<-Map(as.integer,t)
    #oznake<-ttt
    #lables1 <- round(t2/sum(t2)*100,1)
    
    #pie3D(plotData, labels = oznake, explode = 0.1, main = "Zlocini")
    #pie(t2,main="Zlocini",labels=lables1,cex=0.8)
    #legend("topleft", oznake, cex=0.8)
  })
  
  
  # Spremljamo, kako se spreminja zoom
  observe({
    z <- input$zzz
    updateSliderInput(session, "zzz", value = z)
  })
  
  # Zemljevid, trenutno samo za City od London
  output$map <- renderPlot({
    crimes <- tbl.zlocin %>% data.frame()
    zemljevid <- qmap(input$mesto_zemljevid, zoom = 14, maptype = 'hybrid')
    zemljevid + geom_point(data = crimes, aes(x = gsirina, y = gdolzina), color="red", size=2, alpha=0.5)
  })
  
  # Tekst pod zemljevidom, samo testno
  output$text1 <- renderText({ 
    paste("Izbrali ste mesto", input$mesto_zemljevid, "Zoom:", input$zzz)
  })
  
  
})