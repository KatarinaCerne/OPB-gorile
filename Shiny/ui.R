library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Zlocini"),
  
  sidebarLayout(
    sidebarPanel(
tableOutput("zlocini")
    ),
mainPanel("zlocini")
    
    )
  )
)
