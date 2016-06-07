library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
library(ggmap)
library(RColorBrewer)
library(sqldf)

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
  
  
  output$preiskave <- renderPlot({
    pr_podatki <- paste(input$podatek)
    #bi se dalo to kako bolj elegantno?
    
    if(pr_podatki == "gender"){
      #  data1 <- tbl.preiskava
      #  for(element in input$checkGroup){
      #    if (element == "spol"){
      #      data2 <- data1%>%group_by(spol)%>%summarise(count=count(spol))%>%data.frame()
      #    }
      #    else if (element == "uradnarasa"){
      #    kombinacija <- data1$spol%>%data.frame()%>%View
      #    data1 <- cbind(kombinacija,data1)
      #    data2 <- data1%>%group_by(kombinacija)%>%summarise(count=count(kombinacija))%>%data.frame()
      #    }
      #}
      plotData1 <- tbl.preiskava %>% group_by(spol)%>%summarise(count=count(spol))%>%data.frame()
      #  plotData1 <- data2
      ggplot(plotData1, aes(x = factor(1), y = count, fill = spol)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y") + 
        xlab("") + 
        ylab("") + 
        scale_fill_discrete(name="Gender")
    }
    else if (pr_podatki == "age"){
      plotData1 <- tbl.preiskava %>% group_by(starostmin)%>%summarise(count=count(starostmin))%>%data.frame()
      
      ggplot(plotData1, aes(x = factor(1),y=count,fill = factor(starostmin)) )+ 
        geom_bar(stat = "identity", width = 1) + 
        coord_polar(theta = "y") + 
        xlab("") + 
        ylab("") + 
        scale_fill_discrete(name="Age")
    }
    else if (pr_podatki == "race"){
      plotData1 <- tbl.preiskava %>% group_by(rasa)%>%summarise(count=count(rasa))%>%data.frame()
      ggplot(plotData1, aes(x = rasa, y = count, fill = rasa)) + 
        geom_bar(stat = "identity", width = 1) +
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
      
      #theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position = 'none')
      
    }
    else if (pr_podatki == "official race"){
      plotData1 <- tbl.preiskava %>% group_by(uradnarasa)%>%summarise(count=count(uradnarasa))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = uradnarasa)) + 
        geom_bar(stat = "identity", width = 1)  + coord_polar(theta = "y")+
        xlab("") + 
        ylab("") + 
        scale_fill_discrete(name="Official race")
    }
    else if (pr_podatki == "object of search"){
      plotData1 <- tbl.preiskava %>% group_by(predmetpreiskave)%>%summarise(count=count(predmetpreiskave))%>%data.frame()
      ggplot(plotData1, aes(x = predmetpreiskave, y = count, fill = predmetpreiskave)) + 
        geom_bar(stat = "identity", width = 1) + 
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "outcome"){
      plotData1 <- tbl.preiskava %>% group_by(stanje)%>%summarise(count=count(stanje))%>%data.frame()
      ggplot(plotData1, aes(x = stanje, y = count, fill = stanje)) + 
        geom_bar(stat = "identity", width = 1) + 
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "type"){
      plotData1 <- tbl.preiskava %>% group_by(tip)%>%summarise(count=count(tip))%>%data.frame()
      ggplot(plotData1, aes(x = factor(1), y = count, fill = tip)) + 
        geom_bar(stat = "identity", width = 1) + coord_polar(theta = "y")+
        xlab("") + 
        ylab("") + 
        scale_fill_discrete(name="Type")
    }
  })
  
  
  
  output$zlocini_graph <- renderPlot({
    zlocin <- tbl.zlocin %>% data.frame()
    lsoa <- tbl.lsoa %>% data.frame()
    #data <- merge(x = zlocin, y = lsoa, by = NULL) %>% group_by(lsoa) %>% summarise(count = count(lsoa)) %>% data.frame() %>% table()
    sqldf("SELECT COUNT(*) FROM zlocin") %>% table()
    
    #plotData <- tbl.zlocin %>% group_by(status) %>%
    #  summarise(count = count(status)) %>% data.frame()
    #ggplot(data=plotData, aes(x = status, y = count, fill = status)) +
    #  geom_bar(colour="black", stat = "identity", width = 1) + 
    #  xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    
    #data1 <- tbl.zlocin %>% group_by(ukrepal,mesec)%>% summarise(count = count(mesec)) %>% data.frame()%>%View
    #data <- tbl.zlocin %>%filter(ukrepal=="City of London Police")%>%group_by(mesec) %>% summarise(count = count(mesec)) %>% data.frame()%>%View
  })
  
  output$graph <- renderPlot({
    vrstap=paste(input$vrstapod,sep=" ")
    if (vrstap=="crime"){
      tbl.nova <- tbl.zlocin
    }
    else if (vrstap=="stop & search"){
      tbl.nova <- tbl.preiskava
    }
    
    if (input$checkbox_z && input$checkbox_p){
      data <- tbl.nova %>% group_by(ukrepal,mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
      
    }
    else if (input$checkbox_z){
      data <- tbl.nova %>% filter(ukrepal=="City of London Police") %>% group_by(ukrepal,mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
    }
    else if (input$checkbox_p){
      data <- tbl.nova %>% filter(ukrepal=="Cleveland Police") %>% group_by(ukrepal,mesec) %>% summarise(count = count(mesec)) %>% data.frame()
      maksi <- max(data[["count"]]) + 50
    }
    else if (is.data.frame(data) == FALSE) {
      mesec <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
      count <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      maksi <- 100 
      ukrepal <- "Select force"
      data <- data.frame(mesec, count, ukrepal)
    }
    
    ggplot(data=data, aes(x=mesec, y=count, fill=ukrepal))+geom_bar( stat="identity", position="dodge") +
      scale_x_discrete(limit = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                       labels = c("jan","feb","mar", "apr", "may", "jun", "jul", "avg", "sep", "oct", "nov", "dec")) + 
      ylim(0, maksi) + 
      scale_fill_discrete(name="Force")
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
        data = data, colour = "#DF0101", size = 3
      )
      })

  # Zemljevid2
  output$map2 <- renderPlot({
    gc <- input$mesto_zemljevid2
    if (gc == "City of London"){
      map2 <- qmap(gc, source = "stamen", zoom = 14, maptype = "toner", darken = c(.3,"#BBBBBB"))
      size <- 5
    }
    else if (gc == "Middlesbrough"){
      map2 <- qmap(gc, source = "stamen", zoom = 11, maptype = "toner", darken = c(.3,"#BBBBBB"))
      size <- 2
    }
    data <- tbl.zlocin %>% data.frame()
    map2 +
      geom_point(
        data = data,
        aes(x = gsirina, y = gdolzina),
        colour = "#0B0B3B", alpha =.03, size = size
      )
  })
  
  output$map3 <- renderPlot({
    data <- tbl.zlocin %>% filter(ukrepal=="Cleveland Police") %>% group_by(ukrepal, lsoa) %>% data.frame()
    map3 <- ggplot() + ggtitle("Porazdelitev zlocinov -- Cleveland Police") + xlab("Geografska sirina") + ylab("Geografska dolzina") + geom_boxplot() + theme(
      plot.title = element_text(color = "red", size = 18, face = "bold"),
      axis.title.x = element_text(color = "#08298A", size = 14, face = "bold"),
      axis.title.y = element_text(color = "#08298A", size = 14, face = "bold")
    )
    map3 +
      geom_point(data = data, 
                 aes(x = gsirina, y = gdolzina), 
                 color="#08298A", fill="#FFFF3309", size=1.3)
  })
  
})