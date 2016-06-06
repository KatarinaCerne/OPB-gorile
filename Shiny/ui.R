library(shiny)

shinyUI(navbarPage("Zlocini UK",
                   tabPanel("Domov",
                            mainPanel("Nahajate se v aplikaciji Zlocini UK, kjer so zbrani osnovni podatki o zlocinih v UK.",
                                      tags$br(),
                                      "V naslednjih zavihkih se nahajajo razno razne analize, prikazi in grafi.")
                   ),
                   tabPanel("Zlocini",
                            #sidebarLayout(
                              mainPanel(plotOutput("zlocini_graph"))
                   ),
                   tabPanel("Preiskave",
                            sidebarLayout(
                              mainPanel(plotOutput("preiskave")),
                              sidebarPanel(selectInput("podatek",
                                                       label = "Izberi vrsto podatkov",
                                                       choices = c("spol", "starost", "rasa","uradna rasa", "predmet preiskave","stanje","tip"),
                                                       selected = "spol")
                                           #checkboxGroupInput("checkGroup", label = h3("Filtriraj"), 
                                           #                  choices = list("spol" = "spol", "starost" = "starost", "uradna rasa" = "uradnarasa", "tip" = "tip"),
                                           #                  selected = "spol"),
                                           #hr(),
                                           #fluidRow(column(3, verbatimTextOutput("value")))
                            )
                   )
                   ),
                   tabPanel("Zemljevid",
                            sidebarLayout(
                              sidebarPanel(
                                helpText("Na desnem zemljevidu so markirani zlocini, ki so se zgodili v izbranem policijskem okrozju."),
                                selectInput("mesto_zemljevid", 
                                            label = "Izberi mesto prikaza",
                                            choices = list("City Of London"="City of London", "Cleveland"="Middlesbrough"),
                                            selected = "City of London"),
                                selectInput("tip_zemljevid",
                                            label = "Izberi tip prikaza zemljevida",
                                            choices = c('satellite', 'hybrid', 'terrain', 'toner', 'watercolor'),
                                            selected = 'satellite'),
                                sliderInput("zoom",
                                            label = "Zoomiranje zemljevida",
                                            min = 5, max = 20, value = 14, step = 1)
                                           ),
                              mainPanel(plotOutput("map"))
                            )
                   ),
                   tabPanel("Zemljevid2",
                            sidebarLayout(
                              sidebarPanel(
                                helpText("Prikazani zemljevid ima bolj osencene predele, kjer se je zgodilo vec zlocinov."),
                                selectInput("mesto_zemljevid2", 
                                            label = "Izberi mesto prikaza",
                                            choices = list("City Of London"="City of London", "Cleveland"="Middlesbrough"),
                                            selected = "City of London")
                                #sliderInput("zoom2",
                                #            label = "Zoomiranje zemljevida",
                                #            min = 5, max = 20, value = 11, step = 1)
                              ),
                              mainPanel(plotOutput("map2"))
                            )
                   ),
                   tabPanel("Mesecno st. ukrepanj",
                            sidebarLayout(
                              sidebarPanel(selectInput("vrstapod",
                                                       label = "Izberi vrsto podatka",
                                                       choices = c("Zlocin", "Preiskava"),
                                                       selected = "Zlocin"),
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