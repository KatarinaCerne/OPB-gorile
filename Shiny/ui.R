library(shiny)
library(shinythemes)

shinyUI(navbarPage("Crimes in the UK", theme = shinytheme("flatly"),
                   tabPanel("Home",
                            mainPanel("Welcome to Crimes in the UK, an application that contains some basics information about crimes and stop-and-search investigations in the UK. ",
                                      tags$br(),
                                      "In the following tabs you will find some analitics of the data, represented with graphs and maps.")
                   ),
                   tabPanel("Crimes", icon = icon("fa fa-bar-chart", lib = "font-awesome"),
                            #sidebarLayout(
                              mainPanel(plotOutput("zlocini_graph"))
                   ),
                   tabPanel("Stop and searches", icon = icon("fa fa-pie-chart", lib = "font-awesome"),
                            sidebarLayout(
                              mainPanel(plotOutput("preiskave")),
                              sidebarPanel(selectInput("podatek",
                                                       label = "Select type of data",
                                                       choices = c("gender", "age", "race","official race", "object of search","outcome","type"),
                                                       selected = "gender")
                                           #checkboxGroupInput("checkGroup", label = h3("Filtriraj"), 
                                           #                  choices = list("spol" = "spol", "starost" = "starost", "uradna rasa" = "uradnarasa", "tip" = "tip"),
                                           #                  selected = "spol"),
                                           #hr(),
                                           #fluidRow(column(3, verbatimTextOutput("value")))
                            ))
                   ),
                   navbarMenu("Maps", icon = icon("fa fa-globe", lib = "font-awesome"),
                              tabPanel("Map", 
                                       sidebarLayout(
                                         sidebarPanel(
                                           helpText("The dots on the map mark the location of crimes that fall within the selected force."),
                                           selectInput("mesto_zemljevid", 
                                                       label = "Select city",
                                                       choices = list("City Of London"="City of London", "Cleveland"="Middlesbrough"),
                                                       selected = "City of London"),
                                           selectInput("tip_zemljevid",
                                                       label = "Select type of map",
                                                       choices = c('satellite', 'hybrid', 'terrain', 'toner', 'watercolor'),
                                                       selected = 'satellite'),
                                           sliderInput("zoom",
                                                       label = "Map zoom",
                                                       min = 5, max = 20, value = 14, step = 1)
                                         ),
                                         mainPanel(plotOutput("map"))
                                       )
                              ),
                              tabPanel("Map2",
                                       sidebarLayout(
                                         sidebarPanel(
                                           helpText("The shade of the marks on this map represents the number of crimes, that were commited in a certan area.",
                                                    tags$br(),
                                                    "The darker the mark the more crimes were commited."),
                                           selectInput("mesto_zemljevid2", 
                                                       label = "Select city",
                                                       choices = list("City Of London"="City of London", "Cleveland"="Middlesbrough"),
                                                       selected = "City of London")
                                           #sliderInput("zoom2",
                                           #            label = "Zoomiranje zemljevida",
                                           #            min = 5, max = 20, value = 11, step = 1)
                                         ),
                                         mainPanel(plotOutput("map2"))
                                       )
                              ),
                              tabPanel("Map3",
                                       sidebarLayout(
                                         sidebarPanel(
                                           helpText("This map currently works just for Cleveland")
                                         ),
                                         mainPanel(plotOutput("map3"))
                                       )
                              )
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
                                                         label = "Cleveland", value = TRUE)
                                           ),
                              mainPanel(plotOutput("graph"),
                                        textOutput("text_graph"))
                            )
                   )
))