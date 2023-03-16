library(shiny)
library(ggplot2)
#library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(shinyWidgets)
library(leaflet)
library(rgdal)
library(shinydashboard)

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
    )
  ),
  shinydashboard::dashboardBody(
    shiny::tabsetPanel(
      # First tab for map
      shiny::tabPanel(
        "Crime Map",
        id = "tab2",
        shiny::fluidRow(
          shinydashboard::box(
            title = "Crime Map",
            leafletOutput("CrimeMap", height = "600px"),
            width = 12
          )
        )
      ),
      # Second tab for plots
      shiny::tabPanel(
        "Number of crimes",
        id = "tab1",
        shiny::fluidRow(
          shinydashboard::box(
            title = "Average Number of Crimes by Time",
            plotlyOutput(outputId = 'crime_hour_plot'),
            width = 6
          ),
          shinydashboard::box(
            title = "Trend of total number of crimes",
            plotlyOutput(outputId = 'crime_neighbourhood_plot'),
            width = 6
          )
        ),
        shiny::fluidRow(
          shinydashboard::box(
            title = "Number of crimes by type",
            plotlyOutput(outputId = 'crime_type_plot'),
            width = 12
          )
        )
      ),
      # Third tab for learn more
      shiny::tabPanel(
        "Learn More",
        id = "tab3",
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
  df_select <- shiny::reactive({
    df |>
      dplyr::filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood,
             TYPE %in% input$crimetype) |>
      dplyr::add_count(TYPE)
  })
  
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
                 label = "Please select at least two years.",
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
}

thematic::thematic_shiny()
shiny::shinyApp(ui, server)