library(dplyr)
library(shiny)
library(readr)
library(bslib)
library(echarts4r)

path <- file.path("data", "wpp_2022.rds")
data <- read_rds(path) |> 
  mutate(pop_jan_total = pop_jan_total*1000)

# Define your UI
ui <- page_sidebar(
  
  # Apply a custom theme using Bootstrap 5
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  # Sidebar content with select input
  sidebar = sidebar(
    width = 300,  # Set custom width for the sidebar
    div(
      h3("Country Selector"),
      selectInput("country", "Select one or more countries:",
                  choices = unique(data$ISO3),
                  selected = "KOR", 
                  multiple = TRUE)  # Enable multiple selection
    )
  ),
  
  # Main panel with plot output using echarts4r
  div(
    # Title and data source
    titlePanel(
      title = tagList(
        tags$div("World Population Prospects", style = "font-size: 24px;"),  # Main title
        tags$div("Data Source: World Population Prospects 2022, UN", style = "font-size: 14px; color: gray;")  # Subtitle below
      )
    ),
    
    # Output for population trend plot using echarts4r
    echarts4rOutput("popTrend", height = "500px")
  )
)

# Define server logic
server <- function(input, output) {
  
  # Filter data based on selected countries
  countryData <- reactive({
    data |> 
      filter(ISO3 %in% input$country)  # Filter based on selected countries
  })
  
  # Generate the population trend plot using echarts4r
  output$popTrend <- renderEcharts4r({
    filtered_data <- countryData()
    
    if (nrow(filtered_data) == 0) {
      return(NULL)  # Don't plot if no data is selected
    }
    
    # Get the range of years from the data
    min_year <- min(filtered_data$year, na.rm = TRUE)
    max_year <- max(filtered_data$year, na.rm = TRUE)
    
    # Plot using echarts4r
    filtered_data |>
      group_by(ISO3) |> 
      e_charts(year) |>
      e_line(serie = pop_jan_total, symbolSize = 2, bind = region_name) |> 
      e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      return 'Year: ' + params.value[0] + '<br>' +
             'Country Name: ' + params.name + '<br>' +
             'Total Population: ' + params.value[1].toLocaleString();
    }
  ")) |>
      e_title("Population Trend by Country") |>
      e_legend(show = TRUE, bottom = 0) |>
      e_x_axis(name = "Year", min = min_year, max = max_year) |>
      e_y_axis(name = "Population") |>
      e_theme("minty")  # Apply 'minty' theme for consistent look
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
