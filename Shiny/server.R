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
  })
  
  output$line_graph <- renderPlot({
    city <- paste(input$city, "Police", sep = " ")
    if (input$checkbox_z && input$checkbox_p){
      data1 <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      data2 <- tbl.postopek %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      data <- rbind(data1, data2)
    }
    else if (input$checkbox_z){
      data <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
    }
    else if (input$checkbox_p){
      data <- tbl.postopek %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
    }
    ggplot(data=data, aes(x=mesec, y=count, fill=mesec)) + 
      geom_bar(colour="black", width=.8, stat="identity") + 
      scale_x_discrete(limit = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                       labels = c("jan","feb","mar", "apr", "may", "jun", "jul", "avg", "sep", "oct", "nov", "dec")) +
      theme(legend.position='none')
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