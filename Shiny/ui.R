library(shiny)

shinyUI(navbarPage("Zlocini UK",
                   tabPanel("Domov",
                            mainPanel("Nahajate se v aplikaciji Zlocini UK, kjer so zbrani osnovni podatki o zlocinih v UK.",
                                      tags$br(),
                                      "V naslednjem zavihku je tabela zlocinov, vendar moras malcek pocakati, da se nalozi.")
                   ),
                   tabPanel("Zlocini",
                            #sidebarLayout(
                              mainPanel(plotOutput("postopkiPita"))
                              #,sidebarPanel(tableOutput("zlocini"))
                            #)
                      
                   ),
                   tabPanel("Preiskave",
                            sidebarLayout(
                              mainPanel(plotOutput("preiskave")),
                              sidebarPanel(selectInput("podatek",
                                                       label = "Izberi vrsto podatkov",
                                                       choices = c("spol", "starost", "rasa","uradna rasa", "predmet preiskave","stanje","tip"),
                                                       selected = "spol")
                              
                            )
                   )
                   ),
                   tabPanel("Zemljevid",
                            sidebarLayout(
                              sidebarPanel(
                                helpText("Na desnem zemljevidu so markirani zlocini, ki so se zgodili v City of London."),
                                selectInput("mesto_zemljevid", 
                                            label = "Izberi mesto prikaza",
                                            choices = c("City Of London", "Ljubljana",
                                                        "Liverpool"),
                                            selected = "City of London"),
                                
                                sliderInput("zzz", 
                                            label = "Zoomiranje zemljevida:",
                                            min = 0, max = 100, value = 14, step = 1)
                                           ),
                              mainPanel(plotOutput("map"),
                                        textOutput("text1"))
                            )
                   ),
                   tabPanel("Mesecno st. ukrepanj",
                            sidebarLayout(
                              sidebarPanel(selectInput("city",
                                                       label = "Izberi mesto prikaza",
                                                       choices = c("City of London", "Cleveland"),
                                                       selected = "City of London"),
                                           checkboxInput("checkbox_z", 
                                                         label = "Zlocin", value = TRUE),
                                           checkboxInput("checkbox_p", 
                                                         label = "Preiskava", value = TRUE)
                                           ),
                              mainPanel(plotOutput("graph"),
                                        textOutput("text_graph"))
                            )
                            
                   )
                   
)
)