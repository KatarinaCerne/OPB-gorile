library(shiny)
library(shinythemes)

shinyUI(navbarPage("Crimes in the UK", theme = shinytheme("flatly"),
                   tabPanel("Home",
                            mainPanel(h4("Welcome to"), h1("Crimes in the UK,"), h4("an application that contains some basics information about crimes and stop-and-search investigations in the UK."),
                                      tags$br(),
                                      p("In the following tabs you will find some analitics of the data, represented with graphs and maps."),
                                      tags$div(class="header", checked=NA,
                                               tags$p("Our application only includes data from forces of Cleveland Police and City of London Police. Data from other forces is available on the link below."),
                                               tags$a(href="https://data.police.uk/data/", "Click here and download more data if you want :) ")
                                                )
                                      )
                   ),
                   
                   tabPanel("Crimes", icon = icon("fa fa-bar-chart", lib = "font-awesome"),
                            fluidPage(
                              fluidRow(
                                column(6, h3("Crimes by their outcome"),
                                       plotOutput("zlocini_graph")),
                                column(6,
                                       h3("Crimes by type"), plotOutput("zlocini_graph1"))
                                       )
                                      )
                   ),
                   
                   tabPanel("Stop and searches", icon = icon("fa fa-pie-chart", lib = "font-awesome"),
                            sidebarLayout(
                              mainPanel(plotOutput("preiskave")),
                              sidebarPanel(selectInput("podatek",
                                                       label = "Select type of data",
                                                       choices = c("gender", "age", "race","official race", "object of search","outcome","type"),
                                                       selected = "gender"),
                                           helpText(p("Stop-and-search investigation is a type of investigation
                                                    where police stops individuals who are suspected of carrying anything
                                                    illegal and questions and searches them."),br(),
                                                    p("The charts represent data about stop-and-searches regarding 
                                                      age of stopped individuals, their race etc.")
                                                        )
                              
                              ))
                   ),
                   
                   navbarMenu("Maps", icon = icon("fa fa-globe", lib = "font-awesome"),
                              tabPanel("Map with crime marks", 
                                       sidebarLayout(
                                         sidebarPanel(
                                           helpText(p("The dots on the map mark the location of crimes that fall within the selected force."),
                                                    br(),
                                                    p("It may take some time to load the map."), 
                                                    strong("Please, be patient.")
                                                    ),
                                           selectInput("mesto_zemljevid", 
                                                       label = "Select city",
                                                       choices = list("City Of London"="One New Change, London", "Cleveland"="Middlesbrough"),
                                                       selected = "City of London"),
                                           selectInput("tip_zemljevid",
                                                       label = "Select type of map",
                                                       choices = c('satellite', 'hybrid', 'terrain', 'toner', 'watercolor'),
                                                       selected = 'satellite'),
                                           sliderInput("zoom",
                                                       label = "Map zoom",
                                                       min = 5, max = 20, value = 14, step = 1)
                                         ),
                                         mainPanel(conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                                    tags$div("Loading...",id="loadmessage")
                                         ), plotOutput("map"))
                                       )
                              ),
                              
                              tabPanel("General crime maps",
                                      fluidPage(position = "right",
                                        fluidRow(
                                          column(5,
                                            conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                                        tags$div("Loading...",id="loadmessage")
                                                         )
                                                  )
                                                ),
                                        fluidRow(
                                          column(4,
                                            h3("City of London's map"),plotOutput("map2london")
                                          ),
                                          column(4,
                                            h3("Cleveland's map"),plotOutput("map2cleveland")
                                          ),
                                          column(3,
                                                 helpText(
                                                   br(),
                                                   br(),
                                                   br(),
                                                   p("The shade of the marks on this map represents the number of crimes that were commited in a certain area."),
                                                   br(),
                                                   p("The darker the mark the more crimes were commited."),
                                                   br(),
                                                   p("It may take some time to load the maps."), 
                                                   strong("Please, be patient.")
                                                 )
                                          )
                                        )
                                      )
                                      ),
    
                                      
                              tabPanel("Crime distribution maps",
                                       fluidPage(position = "right",
                                          fluidRow(
                                            column(5,
                                              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                                          tags$div("Loading...",id="loadmessage")
                                                          )
                                                   )
                                                 ),
                                         fluidRow(
                                           column(4,
                                            h3("City of London's crime distribution map"),
                                            plotOutput("map3london")
                                          ),
                                          column(4,
                                            h3("Cleveland's crime distribution map"),
                                            plotOutput("map3cleveland")
                                          ),
                                          column(3,
                                                helpText(
                                                  br(),
                                                  br(),
                                                  br(),
                                                  p("On the left you see crime distribution maps."),
                                                  br(),
                                                  p("The crimes that were commited are represented with dots which have the coordinates (longitude, latitude) at geographic coordinate system."),
                                                  br(),
                                                  p("It may take some time to load the maps."), 
                                                  strong("Please, be patient.")
                                                ))
                                         )))
                        
                    ),
                   tabPanel("Yearly statistics", icon = icon("fa fa-bar-chart", lib = "font-awesome"),
                            sidebarLayout(
                              sidebarPanel(selectInput("vrstapod",
                                                       label = "Select data type",
                                                       choices = c("crime", "stop & search"),
                                                       selected = "crime"),
                                           checkboxInput("checkbox_z", 
                                                         label = "City of London", value = TRUE),
                                           checkboxInput("checkbox_p", 
                                                         label = "Cleveland", value = TRUE),
                                           helpText("The graph shows the number of crimes/stop-and-searches in a chosen city.")
                                           ),
                              mainPanel(plotOutput("graph"),
                                        textOutput("text_graph"))
                            )
                   
)))