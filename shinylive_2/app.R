library(shiny)
library(leaflet)
library(plotly)
library(tidyverse)
library(spData)
library(sf)

data(world)
world <- st_as_sf(world)

path <- file.path("../shinylive_1/data", "wpp_2022.rds")
wpp_2022 <- read_rds(path)

my_wpp <- wpp_2022 |> 
  filter(year == 2024)

world_data <- world |>
  left_join(my_wpp, join_by(iso_a2 == ISO2))


# Define your ui and server code here
ui <- fluidPage(
  titlePanel("World Population Prospects"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("continent", "Select a Continent:",
                  choices = c(unique(world_data$continent),
                              unique(world_data$subregion)),
                  selected = "Asia")
    ),
    
    mainPanel(
      plotOutput("continentMap")
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  # Filter data based on selected continent
  continentData <- reactive({
    world_data |> 
      filter((continent == input$continent) |
               (subregion == input$continent))
  })
  
  
  # Generate the map output
  output$continentMap <- renderPlot({
    ggplot(data = continentData()) +
      geom_sf(aes(fill = TFR)) +
      coord_sf(crs = "+proj=robin") +
      scale_fill_viridis_c() +
      scale_x_continuous(breaks = seq(-180, 180, 30)) +
      scale_y_continuous(breaks = c(-89.5, seq(-60, 60, 30), 89.5)) +
      theme(
        panel.background = element_rect("white"),
        panel.grid = element_line(color = "gray80")
      )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)