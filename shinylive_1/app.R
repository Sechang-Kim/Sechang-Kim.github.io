library(ggplot2)
library(dplyr)
library(shiny)

# Define your ui and server code here
ui <- fluidPage(
  titlePanel("World Population Prospects"),
  
  mainPanel(
    dataTableOutput("popTrend")
  )
)


# Define server logic
server <- function(input, output) {
  
  output$popTrend <- renderDataTable({
    data |> head(10) |> 
      DT::datatable()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)