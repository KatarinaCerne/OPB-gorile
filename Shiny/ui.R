
library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Zločini"),
  
  sidebarLayout(
    sidebarPanel(
tableOutput("zlocini")
    ),
mainPanel("zlocini")
    
    )
  )
)
