library(shiny)

shinyUI(navbarPage("Zlocini UK",
                   tabPanel("Domov",
                            mainPanel("Nahajate se v aplikaciji Zlocini UK, kjer so zbrani osnovni podatki o zlocinih v UK.",
                                      tags$br(),
                                      "V naslednjem zavihku je tabela zlocinov, vendar moras malcek pocakati, da se nalozi.")
                   ),
                   tabPanel("Tabelica zlocinov",
                            sidebarLayout(
                              sidebarPanel(plotOutput("postopkiPita")),
                              mainPanel(tableOutput("zlocini"))
                            )
                      
                   ),
                   tabPanel("Postopki",
                            sidebarLayout(
                              sidebarPanel(""),
                              mainPanel(tableOutput("postopki"))
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
                   )
                   
)
)