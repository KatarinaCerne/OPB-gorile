library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
#library(ggmap)

#source("auth.R")
source("auth_public.R")

shinyServer(function(input, output, clientData, session) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.postopek <- tbl(conn, "postopek")
  tbl.preiskava <- tbl(conn, "preiskava")
  #tbl.lokacija <- tbl(conn, "lokacija") tole zakomentiramo, ni v bazi
  tbl.lsoa <- tbl(conn, "lsoa")
  ttt <- tbl.zlocin %>% select(status) %>% group_by(status)%>%data.frame()
  
  
  output$zlocini <- renderTable({
    t <- tbl.zlocin %>% select(status) %>% group_by(status) %>% summarise(stevilo=n())%>% select(stevilo)%>%data.frame()
    #t2<-unlist(t)%>%table()
    #
  })

  
  output$preiskave <- renderPlot({
    pr_podatki <- paste(input$podatek)
    #bi se dalo to kako bolj elegantno?
    if(pr_podatki == "spol"){
      plotData1 <- tbl.preiskava %>% group_by(spol)%>%summarise(count=count(spol))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = spol)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    else if (pr_podatki == "starost"){
      plotData1 <- tbl.preiskava %>% group_by(starostmin)%>%summarise(count=count(starostmin))%>%data.frame()
      
      ggplot(data=plotData1, aes(x=starostmin, y=count, fill=starostmin)) + 
        geom_bar(colour="black", width=1.3, stat="identity") + 
        scale_x_discrete(limit = c("10", "18", "25", "34"),
                         labels = c("10-17","18-24","25-33", "34-")) +
        theme(legend.position='none')
      #popravi tako, da bo napisal lables!!
      
      #ggplot(plotData1, aes(x = factor(1), y = count, fill = starostmin)) + 
       # geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        #xlab("") + ylab("")
    }
    else if (pr_podatki == "rasa"){
      plotData1 <- tbl.preiskava %>% group_by(rasa)%>%summarise(count=count(rasa))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = rasa)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    else if (pr_podatki == "uradna rasa"){
      plotData1 <- tbl.preiskava %>% group_by(uradnarasa)%>%summarise(count=count(uradnarasa))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = uradnarasa)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    else if (pr_podatki == "predmet preiskave"){
      plotData1 <- tbl.preiskava %>% group_by(predmetpreiskave)%>%summarise(count=count(predmetpreiskave))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = predmetpreiskave)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    else if (pr_podatki == "stanje"){
      plotData1 <- tbl.preiskava %>% group_by(stanje)%>%summarise(count=count(stanje))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = stanje)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    #manjka še za tip
  })
  
  
  output$postopkiPita <- renderPlot({
    plotData <- tbl.zlocin %>% group_by(status) %>%
      summarise(count = count(status)) %>% data.frame()
    ggplot(plotData, aes(x = factor(1), y = count, fill = status)) +
      geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") +
      xlab("") + ylab("")
    #dokaj nepregledno. alternativa?
  })
  
  output$graph <- renderPlot({
    city <- paste(input$city, "Police", sep = " ")
    
    if (input$checkbox_z && input$checkbox_p){
      data1 <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      data2 <- tbl.preiskava %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data1[["count"]]) + max(data2[["count"]]) 
      data <- rbind(data1, data2)
    }
    else if (input$checkbox_z){
      data <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) 
    }
    else if (input$checkbox_p){
      data <- tbl.preiskava %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) 
    }
    
    if (is.data.frame(data) == FALSE) {
      mesec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
      count <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      data <- data.frame(mesec, count)
      maksi <- 100 
    } 
    
    ggplot(data=data, aes(x=mesec, y=count, fill=mesec)) + 
      geom_bar(colour="black", width=.8, stat="identity") + 
      scale_x_discrete(limit = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                       labels = c("jan","feb","mar", "apr", "may", "jun", "jul", "avg", "sep", "oct", "nov", "dec")) +
      theme(legend.position = 'none') +
      ylim(0, maksi) 
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