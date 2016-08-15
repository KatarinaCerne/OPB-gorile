library(shiny)
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
library(plotrix)
library(ggmap)
library(RColorBrewer)
library(sqldf)
library(scales)


source("auth_public.R")

shinyServer(function(input, output) {
  # Vzpostavimo povezavo
  conn <- src_postgres(dbname = db, host = host,
                       user = user, password = password)
  # Pripravimo tabele
  tbl.zlocin <- tbl(conn, "zlocin")
  tbl.preiskava <- tbl(conn, "preiskava")
  tbl.lsoa <- tbl(conn, "lsoa")
  
  
  output$preiskave <- renderPlot({
    pr_podatki <- paste(input$podatek)
    
    if(pr_podatki == "gender"){
      plotData1 <- tbl.preiskava %>% group_by(spol)%>%summarise(count=count(spol))%>%data.frame()
      plotData1 <- plotData1[order(plotData1[,2]) , ]
      
      midpoint <- cumsum(plotData1[,2]) - plotData1[,2]/2
      
      ggplot(plotData1, aes(x = factor(1), y = count, fill = spol)) + 
        geom_bar(stat = "identity", width = 1) + 
        coord_polar(theta = "y")+xlab("") + ylab("")+
        theme(axis.ticks=element_blank(), axis.title=element_blank(), axis.text.y=element_blank())+
        scale_y_continuous(breaks=midpoint, labels=percent(plotData1[,2]/sum(plotData1[,2])))+
        scale_fill_discrete(name="Gender", 
                            labels=c("No data", "Female", "Male"))
    }
    else if (pr_podatki == "age"){
      plotData1 <- tbl.preiskava %>% group_by(starostmin)%>% summarise(count=count(starostmin))%>% data.frame()
      plotData1 <- plotData1[order(plotData1[,2]) , ]
      
      zalegendo <-c("10-17 years","18-24 years","25-33 years","over 34 years")
      
      midpoint <- cumsum(plotData1[,2]) - plotData1[,2]/2

      ggplot(plotData1, aes(x = factor(1),y=count,fill = factor(starostmin))) +
                geom_bar(stat = "identity", width = 1) + 
                coord_polar(theta = "y") + 
                xlab("") + ylab("") + 
                theme(axis.ticks=element_blank(), axis.title=element_blank(), axis.text.y=element_blank())+
                scale_y_continuous(breaks=midpoint, labels=percent(plotData1[,2]/sum(plotData1[,2]))) +
                scale_fill_discrete(name="Age", 
                                    labels=c("10-17 years", "18-24 years", "25-33 years","over 34 years"))
    }
    else if (pr_podatki == "race"){
      plotData1 <- tbl.preiskava %>% group_by(rasa)%>%summarise(count=count(rasa))%>%data.frame()
      
      ggplot(plotData1, aes(x = replace(rasa, match("", rasa), "No data"), y = count, fill = rasa)) + 
        geom_bar(stat = "identity", width = 1) +
        geom_text(aes(label=count), position=position_dodge(width=0.9), hjust=-0.025) +
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "official race"){
      plotData1 <- tbl.preiskava %>% group_by(uradnarasa)%>%summarise(count=count(uradnarasa))%>%data.frame()
      plotData1 %>% View()
      plotData1 <- plotData1[order(plotData1[,2]) , ]
      
      
      
      midpoint <- cumsum(plotData1[,2]) - plotData1[,2]/2
      
      ggplot(plotData1, aes(x = replace(factor(1), match(" ", factor(1)), "No data"), y = count, fill = uradnarasa)) + 
        geom_bar(stat = "identity", width = 1)  + 
        coord_polar(theta = "y")+
        xlab("") + 
        ylab("") + 
        theme(axis.ticks=element_blank(), axis.title=element_blank(), axis.text.y=element_blank())+
        scale_y_continuous(breaks=midpoint, labels=percent(plotData1[,2]/sum(plotData1[,2])))+
        scale_fill_discrete(name="Official race")
    }
    else if (pr_podatki == "object of search"){
      plotData1 <- tbl.preiskava %>% group_by(predmetpreiskave)%>%summarise(count=count(predmetpreiskave))%>%data.frame()
      
      ggplot(plotData1, aes(x = replace(predmetpreiskave, match("", predmetpreiskave), "No data"), y = count, fill = predmetpreiskave)) + 
        geom_bar(stat = "identity", width = 1) + 
        geom_text(aes(label=count), position=position_dodge(width=0.9), hjust=-0.25) +
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "outcome"){
      plotData1 <- tbl.preiskava %>% group_by(stanje)%>%summarise(count=count(stanje))%>%data.frame()
      
      ggplot(plotData1, aes(x = replace(stanje, match("", stanje), "No data"), y = count, fill = stanje)) + 
        geom_bar(stat = "identity", width = 1) + 
        geom_text(aes(label=count), position=position_dodge(width=0.9), hjust=-0.25) +
        xlab("") + ylab("")+coord_flip()+theme(legend.position = 'none')
    }
    else if (pr_podatki == "type"){
      plotData1 <- tbl.preiskava %>% group_by(tip) %>% summarise(count=count(tip)) %>% data.frame()
      plotData1 <- plotData1[order(plotData1[,2]) , ]
      
      midpoint <- cumsum(plotData1[,2]) - plotData1[,2]/2
      
      ggplot(plotData1, aes(x = factor(1), y = count, fill = tip)) + 
        geom_bar(stat = "identity", width = 1)  + 
        coord_polar(theta = "y")+
        xlab("") + 
        ylab("") + 
        theme(axis.ticks=element_blank(), axis.title=element_blank(), axis.text.y=element_blank())+
        scale_y_continuous(breaks=midpoint, labels=percent(plotData1[,2]/sum(plotData1[,2])))+
        scale_fill_discrete(name="Type of search")
    }
  })
  
  
  
  output$zlocini_graph <- renderPlot({
    plotData <- tbl.zlocin %>% group_by(status) %>% summarise(count = count(status)) %>% data.frame()
    
    ggplot(data=plotData, aes(x = replace(status, match("", status), "No data"), y = count, fill = status)) +
      geom_bar(colour="black", stat = "identity", width = 1) + 
      geom_text(aes(label=count), position=position_dodge(width=0.9), hjust=-0.25) +
      ylim(0, 46500) +
      xlab("") + ylab("") + 
      coord_flip() + theme(legend.position = 'none')
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
    
    ggplot(data=data, aes(x=mesec, y=count, fill=ukrepal), size = 20) + 
      geom_bar( stat="identity", position="dodge") +
      scale_x_discrete(limit = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                       name = "",
                       labels = c("jan","feb","mar", "apr", "may", "jun", "jul", "avg", "sep", "oct", "nov", "dec")) + 
      scale_y_continuous(breaks=c(min(data[["count"]]), max(data[["count"]]))) +
      scale_fill_discrete(name="Force") 
  })
  
  
  # Osnovni zemljevid
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

  # Osencena zemljevida
  output$map2london <- renderPlot({
    gc <- "One New Change, London"
    map2london <- qmap(gc, source = "stamen", zoom = 14, maptype = "toner", darken = c(.3,"#BBBBBB"))
    size <- 5
    data <- tbl.zlocin %>% data.frame()
    map2london +
      geom_point(
        data = data,
        aes(x = gsirina, y = gdolzina),
        colour = "#0B0B3B", alpha =.03, size = size
      )
  })
  
  output$map2cleveland <-renderPlot({
    gc <- "Middlesbrough"
    map2cleveland <- qmap(gc, source = "stamen", zoom = 11, maptype = "toner", darken = c(.3,"#BBBBBB"))
    size <- 2
    data <- tbl.zlocin %>% data.frame()
    map2cleveland +
      geom_point(
        data = data,
        aes(x = gsirina, y = gdolzina),
        colour = "#0B0B3B", alpha =.03, size = size
      )
  })
  
  
  # Zemljevid Clevelanda s porazdelitvijo zlocinov, ggplot
  output$map3cleveland <- renderPlot({
    data <- tbl.zlocin %>% filter(ukrepal=="Cleveland Police") %>% group_by(ukrepal, lsoa) %>% data.frame()
    map3cleveland <- ggplot() + 
      #ggtitle("Crime distribution -- Cleveland Police") + 
      xlab("Longitude") + ylab("Latitude") + geom_boxplot() + theme(
      #plot.title = element_text(color = "red", size = 18, face = "bold"),
      axis.title.x = element_text(color = "#08298A", size = 14, face = "bold"),
      axis.title.y = element_text(color = "#08298A", size = 14, face = "bold")
    )
    map3cleveland +
      geom_point(data = data, 
                 aes(x = gsirina, y = gdolzina), 
                 color="#08298A", fill="#FFFF3309", size=1.3)
  })
  
  # Zemljevid City of Londona s porazdelitvijo zlocinov, ggplot
  output$map3london <- renderPlot({
    data <- tbl.zlocin %>% filter(ukrepal=="City of London Police") %>% group_by(ukrepal, lsoa) %>% data.frame()
    map3london <- ggplot() + 
      #ggtitle("Crime distribution -- City of London Police") + 
      xlab("Longitude") + ylab("Latitude") + geom_boxplot() + theme(
      #plot.title = element_text(color = "red", size = 18, face = "bold"),
      axis.title.x = element_text(color = "#08298A", size = 14, face = "bold"),
      axis.title.y = element_text(color = "#08298A", size = 14, face = "bold")
    )
    map3london +
      geom_point(data = data, 
                 aes(x = gsirina, y = gdolzina), 
                 color="#08298A", fill="#FFFF3309", size=1.3)
  })
  
})