library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
library(ggmap)
library(RColorBrewer)

#source("auth.R")
source("auth_public.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.postopek <- tbl(conn, "postopek")
  tbl.preiskava <- tbl(conn, "preiskava")
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
      
      #ggplot(data=plotData1, aes(x=starostmin, y=count, fill=starostmin)) + 
      #  geom_bar(colour="black", width=1.3, stat="identity") + 
      #  scale_x_discrete(limit = c("10", "18", "25", "34"),
      #                   labels = c("10-17","18-24","25-33", "34-")) +
      #  theme(legend.position='none')
      #popravi tako, da bo napisal lables!!
      
      ggplot(plotData1, aes(x = factor(1), y = count, fill = starostmin)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + ylab("")
    }
    else if (pr_podatki == "rasa"){
      plotData1 <- tbl.preiskava %>% group_by(rasa)%>%summarise(count=count(rasa))%>%data.frame()
      ggplot(plotData1, aes(x = rasa, y = count, fill = rasa)) + 
        geom_bar(stat = "identity", width = 1) +
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
      
      #theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position = 'none')
      
    }
    else if (pr_podatki == "uradna rasa"){
      plotData1 <- tbl.preiskava %>% group_by(uradnarasa)%>%summarise(count=count(uradnarasa))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = uradnarasa)) + 
        geom_bar(stat = "identity", width = 1)  + coord_polar(theta = "y")+
        xlab("") + ylab("")
    }
    else if (pr_podatki == "predmet preiskave"){
      plotData1 <- tbl.preiskava %>% group_by(predmetpreiskave)%>%summarise(count=count(predmetpreiskave))%>%data.frame()
      ggplot(plotData1, aes(x = predmetpreiskave, y = count, fill = predmetpreiskave)) + 
        geom_bar(stat = "identity", width = 1) + 
        #coord_polar(theta = "y") + 
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "stanje"){
      plotData1 <- tbl.preiskava %>% group_by(stanje)%>%summarise(count=count(stanje))%>%data.frame()
      ggplot(plotData1, aes(x = stanje, y = count, fill = stanje)) + 
        geom_bar(stat = "identity", width = 1) + 
        #coord_polar(theta = "y") + 
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    #manjka ťe za tip
  })
  
  
  output$postopkiPita <- renderPlot({
    plotData <- tbl.zlocin %>% group_by(status) %>%
      summarise(count = count(status)) %>% data.frame()
    ggplot(data=plotData, aes(x = status, y = count, fill = status)) +
      geom_bar(colour="black", stat = "identity", width = 1) + 
      #coord_polar(theta = "y") +
      xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
  })
  
  output$graph <- renderPlot({
    city <- paste(input$city, "Police", sep = " ")
    
    if (input$checkbox_z && input$checkbox_p){
      data1 <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      data2 <- tbl.preiskava %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data1[["count"]]) + max(data2[["count"]]) + 50
      data <- rbind(data1, data2)
    }
    else if (input$checkbox_z){
      data <- tbl.zlocin %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
    }
    else if (input$checkbox_p){
      data <- tbl.preiskava %>% filter(ukrepal == city) %>% group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
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
  
  # Zemljevid
  output$map <- renderPlot({
    data <- tbl.zlocin %>% data.frame()
    gc <- geocode(input$mesto_zemljevid)
    map <- get_map(gc, source = "google", zoom = input$zoom, maptype = input$tip_zemljevid)
    ggmap(map) +
      geom_point(
        aes(x = gsirina, y = gdolzina),
        data = data, colour = "red", size = 3
      )
  })

  
})