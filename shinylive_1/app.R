library(readr)
library(ggplot2)
library(dplyr)
library(shiny)

path <- file.path("data", "wpp_2022.rds")
data <- read_rds(path)

# Define your ui and server code here
ui <- fluidPage(
  titlePanel("World Population Prospects"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Select a country:",
                  choices = unique(data$ISO3),
                  selected = "KOR")
    ),
    
    mainPanel(
      plotOutput("popTrend")
    )
  )
)


# Define server logic
server <- function(input, output) {
  
  # Filter data based on selected continent
  countryData <- reactive({
    data |> 
      filter(ISO3 == input$country)
  })
  
  
  # Generate the map output
  output$popTrend <- renderPlot({
    ggplot(data = countryData(), aes(x=year, y=pop_jan_total)) +
      geom_line()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)