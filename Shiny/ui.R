library(shiny)

shinyUI(navbarPage("Zlocini UK",
                   tabPanel("Domov",
                            mainPanel("Nahajate se v aplikaciji Zlocini UK, kjer so zbrani osnovni podatki o zlocinih v UK.",
                            tags$br(),
                            "V naslednjem zavihku je tabela zlocinov, vendar moras malcek pocakati, da se nalozi.")
                   ),
                   tabPanel("Tabelica zlocinov",
                            sidebarLayout(
                              sidebarPanel(tableOutput("zlocini")),
                              mainPanel("zlocini")
                            )
                            )
)
)