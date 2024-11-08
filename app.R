library(shiny)
library(dplyr)
library(readr)
library(bslib)
library(ggplot2)
library(spData)
library(sf)

worldData <- world
world <- st_as_sf(worldData)

# Define your ui and server code here
ui <- page_sidebar(
  
  title = "World Population Prospects",
  
  sidebar = sidebar(
    selectInput(
      inputId = "continent",
      label = "Select a continent: ",
      choices = c("Asia", "Africa", "Europe", "South America",
                  "North America", "Antartica")
    )),
  
  plotOutput("continentMap")
)


# Define server logic
server <- function(input, output) {
  
  data <- reactive({
    world |> 
      filter(continent == input$continent)
  })
  
  # Generate the map output
  output$continentMap <- renderPlot({
    ggplot(data(), aes(x=subregion, y=gdpPercap, fill=iso_a2)) +
      geom_col()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)