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
  
  
  output$zlocini <- renderTable({
    t <- tbl.zlocin %>% select(status) %>% group_by(status) %>% summarise(stevilo=n())%>% select(stevilo)%>%data.frame()
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
      
      ggplot(plotData1, aes(x = factor(1),y=count,fill = factor(starostmin)) )+ 
        geom_bar(stat = "identity", width = 1) + 
        coord_polar(theta = "y") + 
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
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "stanje"){
      plotData1 <- tbl.preiskava %>% group_by(stanje)%>%summarise(count=count(stanje))%>%data.frame()
      ggplot(plotData1, aes(x = stanje, y = count, fill = stanje)) + 
        geom_bar(stat = "identity", width = 1) + 
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    #manjka ťe za tip
  })
  
  
  output$postopkiPita <- renderPlot({
    plotData <- tbl.zlocin %>% group_by(status) %>%
      summarise(count = count(status)) %>% data.frame()
    ggplot(data=plotData, aes(x = status, y = count, fill = status)) +
      geom_bar(colour="black", stat = "identity", width = 1) + 
      xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    
    #data1 <- tbl.zlocin %>% group_by(ukrepal,mesec)%>% summarise(count = count(mesec)) %>% data.frame()%>%View
    #data <- tbl.zlocin %>%filter(ukrepal=="City of London Police")%>%group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()%>%View
  })
  
  output$graph <- renderPlot({
    vrstap=paste(input$vrstapod,sep=" ")
    if (vrstap=="Zlocin"){
      tbl.nova<-tbl.zlocin
    }
    else if (vrstap=="Preiskava"){
      tbl.nova<-tbl.preiskava
    }
    
    if (input$checkbox_z && input$checkbox_p){
      data <- tbl.nova%>%group_by(ukrepal,mesec)%>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
      
    }
    else if (input$checkbox_z){
      data <- tbl.nova %>%filter(ukrepal=="City of London Police")%>%group_by(ukrepal,mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
    }
    else if (input$checkbox_p){
      data <- tbl.nova %>%filter(ukrepal=="Cleveland Police")%>%group_by(ukrepal,mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
    }
    else if (is.data.frame(data) == FALSE) {
      mesec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
      count <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      maksi <- 100 
      ukrepal <- "Izberite policijsko postajo"
      data <- data.frame(mesec, count, ukrepal)
    }
    
    ggplot(data=data, aes(x=mesec, y=count, fill=ukrepal))+geom_bar( stat="identity", position="dodge") +
      scale_x_discrete(limit = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                       labels = c("jan","feb","mar", "apr", "may", "jun", "jul", "avg", "sep", "oct", "nov", "dec"))+ 
      ylim(0, maksi) 
  })
  
  # Zemljevid
  output$map <- renderPlot({
    data <- tbl.zlocin %>% data.frame()
    data2 <- tbl.preiskava %>% data.frame()
    gc <- input$mesto_zemljevid
    map <- get_map(gc, source = "google", zoom = input$zoom, maptype = input$tip_zemljevid)
    ggmap(map, fullpage = TRUE) +
      geom_point(
        aes(x = gsirina, y = gdolzina),
        data = data, colour = "red", size = 3
      )
      })

  output$map2 <- renderPlot({
    gc <- input$mesto_zemljevid2
    zoom <- input$zoom2
    map2 <- qmap(gc, source = "stamen", zoom = zoom, maptype = "toner", darken = c(.3,"#BBBBBB"))
    data <- tbl.zlocin %>% data.frame()
    map2 +
      geom_point(
        data = data,
        aes(x = gsirina, y = gdolzina),
        colour = "dark green", alpha =.03, size = 2
      )
  })
  
})