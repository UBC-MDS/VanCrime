library(shiny)
library(ggplot2)
library(thematic)
library(plotly)
library(tidyverse)
library(shinyWidgets)
library(leaflet)
library(rgdal)
library(shinydashboard)
library(shinycssloaders)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Read data file
df <- read.csv(file = 'data/raw/crimedata_csv_AllNeighbourhoods_AllYears.csv')

# Data wrangling
df[df == ''] <- NA
df <- df |>
  tidyr::drop_na() |>  # Drop NA
  dplyr::filter(YEAR < max(df$YEAR))  |> # Remove the latest year data (not full year in general) 
  dplyr::filter(X != 0 & Y != 0)

# Get year range
year_range <- range(df$YEAR)

# Get unique neighbourhood and crime type
unique_nhood <- sort(unique(df$NEIGHBOURHOOD))
unique_crimetype <- sort(unique(df$TYPE))

# prepare UTM coordinates matrix
# PS: df$X and df$Y are UTM Easting and Northing respectively
# PS: zone= UTM zone, vancouver is UTM10
utmcoor <- sp::SpatialPoints(cbind(df$X, df$Y), proj4string = sp::CRS("+proj=utm +zone=10"))

#From utm to latitude or longtitude
longlatcoor <- data.frame(sp::spTransform(utmcoor, sp::CRS("+proj=longlat")))
colnames(longlatcoor) <- c("Longtitude", "Latitude")
df <- cbind(df, longlatcoor)

# UI
ui <- shinydashboard::dashboardPage(
  shinydashboard::dashboardHeader(title = "Vancouver Crime Data"),
  shinydashboard::dashboardSidebar(
    shiny::sliderInput(
      inputId = "year",
      label = "YEAR:",
      min = year_range[1],
      max = year_range[2],
      value = year_range,
      step = 1,
      sep = ''
    ),
    shinyWidgets::pickerInput(
      inputId = "nhood",
      label = "Select Vancouver Neighbourhood",
      choices = unique_nhood,
      selected = c("Arbutus Ridge", "Central Business District", "Dunbar-Southlands"),
      options = pickerOptions(
        actionsBox = TRUE,
        size = 10,
        selectedTextFormat = "count > 1",
      ),
      multiple = TRUE
    ),
    shinyWidgets::pickerInput(
      inputId = "crimetype",
      label = "Select Types of Crimes",
      choices = unique_crimetype,
      selected = unique_crimetype,
      options = pickerOptions(
        actionsBox = TRUE,
        size = 10,
        selectedTextFormat = "count > 1",
      ),
      multiple = TRUE
    ),
    shinydashboard::box(title = "Help Info ", 
                        status = "primary", 
                        solidHeader = TRUE, 
                        width = 12,
                        p(paste("The crime statistics that have been made public by the Vancouver Police",
                            "Department are the basis for this dashboard. Please choose the neighbourhood of",
                            "interest in order to visualize the crime data that are of interest for the particular",
                            "neighbourhood (such as Fairview or Kitsilano). To narrow your search by category",
                            "of criminal activity, please choose the category of criminal activity (such as Mischief",
                            "or Break and Enter). Please change the year sliders to focus the data on a specific",
                            "from and to year so that the display can be constrained to a certain time period."), 
                        style = 'font-size:14px;color:black;'),
    )
  ),
  shinydashboard::dashboardBody(
    shiny::tabsetPanel(
      id = "tab1",
      # First tab for map
      shiny::tabPanel(
        "Crime Map",
        shiny::fluidRow(
          # tags$style(type="text/css", "#myplot { width: 100%; height: 100%; }"),
          shinydashboard::box(
            title = "Crime Map",
            textOutput("top_3_crime_types"),
            shinycssloaders::withSpinner(
              leafletOutput("CrimeMap", height="450px")
            ),
            width = 12
          )
        )
      ),
      # Second tab for plots
      shiny::tabPanel(
        "Number of crimes",
        shiny::fluidRow(
          shinydashboard::box(
            title = "Average Number of Crimes by Time",
            shinycssloaders::withSpinner(
              plotlyOutput(outputId = 'crime_hour_plot', height='200px')
            ),
            width = 6
          ),
          shinydashboard::box(
            title = "Trend of total number of crimes",
            shinycssloaders::withSpinner(
              plotlyOutput(outputId = 'crime_neighbourhood_plot', height='200px')
            ),
            width = 6
          )
        ),
        shiny::fluidRow(
          shinydashboard::box(
            title = "Number of crimes by type",
            shinycssloaders::withSpinner(
              plotlyOutput(outputId = 'crime_type_plot', height='200px')
            ),
            width = 12
          )
        )
      ),
      # Third tab for learn more
      shiny::tabPanel(
        "Learn More",
        shinydashboard::box(
          HTML("<p>The current project is a dahsbord  for the Vancouver (Canada) crime data released by the Vancouver Police Department (<a href='https://vpd.ca/'>VPD</a>).</p>"),
          HTML("<p>For more information, please visit our GitHub repository at <a href='https://github.com/UBC-MDS/VanCrime'>https://github.com/UBC-MDS/VanCrime</a>.</p>"),
          h4('License'),
          p('The current project was created by Morris Chan, Markus Nam, Andy Wang and Tony Zoght. It is licensed under the terms of the MIT license.'),
          width = 12
        )
      )
    )
  )
)


server <- function(input, output, session) {
  # filter data based on widget values
  df_select <- shiny::reactive({
    validate_data <- df |>
      dplyr::filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood,
             TYPE %in% input$crimetype) |>
      dplyr::add_count(TYPE)
    
    validate(
      missing_values(validate_data)
    )
    
    validate_data
  })
  
  
  missing_values <- function(input_data) {
    if(nrow(input_data) == 0) {
      "Please select neighbourhood(s) and crime type(s)"
    }
    else {
      NULL
    }
  }
  
  
  # Plot - Total Crimes by Type
  output$crime_type_plot <- plotly::renderPlotly({
    if (nrow(df_select()) == 0) {
      ggplot2::ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = "No values selected",
                 size = 8, color = "red", hjust = 0.5, vjust = 0.5) +
        labs(x='Count',
             y='Crime type') +
        theme(text=element_text(family="Arial"),
              plot.title=element_text(family="Arial"),
              plot.subtitle=element_text(family="Arial"),
              axis.title.x=element_text(family="Arial"),
              axis.title.y=element_text(family="Arial"),
              axis.text.x=element_text(family="Arial"),
              axis.text.y=element_text(family="Arial"))
    }
    else {
      plotly::ggplotly(
        ggplot2::ggplot(df_select(), aes(y=reorder(TYPE, -n), fill=TYPE, text=paste0('count: ', n))) +
          geom_bar(stat='count') +
          labs(x='Count',
               y='Crime type') +
          theme(text=element_text(family="Arial"),
                plot.title=element_text(family="Arial"),
                plot.subtitle=element_text(family="Arial"),
                axis.title.x=element_text(family="Arial"),
                axis.title.y=element_text(family="Arial"),
                axis.text.x=element_text(family="Arial"),
                axis.text.y=element_text(family="Arial")) +
          guides(fill='none'),
        tooltip=c('text')
      )
    }
  })

  # Plot - Crime Map
  output$CrimeMap <- leaflet::renderLeaflet({
    leaflet::leaflet(df_select()) %>%
      leaflet::addTiles() %>%
      leaflet::addMarkers(
        lng = ~ Longtitude,
        lat = ~ Latitude,
        label = ~ paste0(TYPE, " (", HOUR, ":", MINUTE, ")"),
        clusterOptions = markerClusterOptions()
      )
  })
  
  # Plot - Total Crimes by Neighbourhood
  output$crime_neighbourhood_plot <- plotly::renderPlotly({
    if (nrow(df_select()) == 0) {
      ggplot2::ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = "No values selected",
                 size = 8, color = "red", hjust = 0.5, vjust = 0.5) +
        labs(x='Year',
             y='Total number of crimes',
             fill='Neighbourhood') +
        theme(text=element_text(family="Arial"),
              plot.title=element_text(family="Arial"),
              plot.subtitle=element_text(family="Arial"),
              axis.title.x=element_text(family="Arial"),
              axis.title.y=element_text(family="Arial"),
              axis.text.x=element_text(family="Arial"),
              axis.text.y=element_text(family="Arial"))
    }
    else if (length(unique(df_select()$YEAR)) <= 1) {
      ggplot2::ggplot() + 
        annotate("text", x = 0.5, y = 0.5,
                 label = "Please select a range of at least two years",
                 size = 5, color = "red", hjust = 0.5, vjust = 0.5) +
        labs(x='Year',
             y='Total number of crimes',
             fill='Neighbourhood') +
        theme(text=element_text(family="Arial"),
              plot.title=element_text(family="Arial"),
              plot.subtitle=element_text(family="Arial"),
              axis.title.x=element_text(family="Arial"),
              axis.title.y=element_text(family="Arial"),
              axis.text.x=element_text(family="Arial"),
              axis.text.y=element_text(family="Arial"))
    }
    else {
      plotly::ggplotly(
        ggplot2::ggplot(df_select(), aes(x=YEAR, fill=NEIGHBOURHOOD)) +
          geom_area(stat='count') +
          labs(x='Year',
               y='Total number of crimes',
               fill='Neighbourhood') +
          theme(text=element_text(family="Arial"),
                plot.title=element_text(family="Arial"),
                plot.subtitle=element_text(family="Arial"),
                axis.title.x=element_text(family="Arial"),
                axis.title.y=element_text(family="Arial"),
                axis.text.x=element_text(family="Arial"),
                axis.text.y=element_text(family="Arial"))
      )
    }
  })

  # Plot - Total Crimes by Hour
  output$crime_hour_plot <- plotly::renderPlotly({
    if (nrow(df_select()) == 0) {
      ggplot2::ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = "No values selected",
                 size = 8, color = "red", hjust = 0.5, vjust = 0.5) +
        labs(x='Time',
             y='Daily Average') +
        theme(text=element_text(family="Arial"),
              plot.title=element_text(family="Arial"),
              plot.subtitle=element_text(family="Arial"),
              axis.title.x=element_text(family="Arial"),
              axis.title.y=element_text(family="Arial"),
              axis.text.x=element_text(family="Arial"),
              axis.text.y=element_text(family="Arial"))
    }
    else {
      df_group <- df_select() |>
        dplyr::group_by(HOUR) |>
        dplyr::summarise(n = n()) |>
        dplyr::mutate(Time = as.factor(paste(HOUR, ':00', sep = '')),
               daily_avg = n / (365 * (input$year[2] - input$year[1] + 1)))
      
      df_group$Time = forcats::fct_relevel(df_group$Time,
                             c('0:00', '1:00', '2:00', '3:00', '4:00',
                               '5:00', '6:00', '7:00', '8:00', '9:00',
                               '10:00', '11:00', '12:00', '13:00', '14:00',
                               '15:00', '16:00', '17:00', '18:00', '19:00',
                               '20:00', '21:00', '22:00', '23:00')
      )
      
      plotly::ggplotly(
        ggplot2::ggplot(df_group, aes(x=Time, y = daily_avg, group = 1)) +
          geom_line() +
          labs(x='Time',
               y='Daily Average') +
          theme(text=element_text(family="Arial"),
                plot.title=element_text(family="Arial"),
                plot.subtitle=element_text(family="Arial"),
                axis.title.x=element_text(family="Arial"),
                axis.title.y=element_text(family="Arial"),
                axis.text.x=element_text(family="Arial"),
                axis.text.y=element_text(family="Arial")) +
          scale_x_discrete(breaks=c('0:00', '3:00', '6:00', '9:00',
                                      '12:00', '15:00', '18:00', '21:00'))
      )
    }
  })
  
  # Text - Top 3 Crimes by Neighbourhood
  output$top_3_crime_types <- shiny::renderText({
    paste0(
      'The most frequent crimes are ',
      df_select() %>%
        dplyr::group_by(TYPE) %>%
        dplyr::summarise(count = n()) %>%
        dplyr::arrange(desc(count)) %>%
        dplyr::slice_head(n = 3) %>%
        dplyr::pull(TYPE) %>%
        paste0(collapse = ", ") 
    )
  })
}

thematic::thematic_shiny()
shiny::shinyApp(ui, server)