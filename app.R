library(shiny)
library(ggplot2)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(shinyWidgets)
library(leaflet)
library(rgdal)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Read data file
df <- read.csv(file = 'data/raw/crimedata_csv_AllNeighbourhoods_AllYears.csv')

# Data wrangling
df[df == ''] <- NA
df <- df |>
  drop_na() |>  # Drop NA
  filter(YEAR < max(df$YEAR))  |> # Remove the latest year data (not full year in general) 
  filter(X != 0 & Y != 0)

# Get year range
year_range <- range(df$YEAR)

# Get unique neighbourhood
unique_nhood <- sort(unique(df$NEIGHBOURHOOD))

# Crime Map ####################################################################
# X and Y coordinates (changed from UTM format to Latitude and longtitude)
# because only latitude and longtitude can be plotted on ggmap

# prepare UTM coordinates matrix
# PS: df$X and df$Y are UTM Easting and Northing respectively
# PS: zone= UTM zone, vancouver is UTM10
utmcoor<-SpatialPoints(cbind(df$X, df$Y), proj4string=CRS("+proj=utm +zone=10"))

#From utm to latitude or longtitude
longlatcoor<-data.frame(spTransform(utmcoor,CRS("+proj=longlat")))

colnames(longlatcoor) <- c("Longtitude", "Latitude")
df <- cbind(df, longlatcoor)
# Crime Map ##################################################################

ui <- navbarPage('Vancouver Crime Data',
                 # Use a theme
                 theme = bslib::bs_theme(bootswatch = 'yeti'),

                 # Tab 1
                 tabPanel('Main',
                          # Side area to host the controls
                          sidebarLayout(
                                         # Sample code for slider (range)
                            sidebarPanel(sliderInput(inputId='year',
                                                     label='YEAR:',
                                                     min=year_range[1],
                                                     max=year_range[2],
                                                     value=year_range,
                                                     step=1,
                                                     sep=''),
                                         pickerInput(
                                           inputId = "nhood", 
                                           label = "Select Vancouver Neighbourhood", 
                                           choices = unique_nhood, 
                                           selected = c("Central Business District"),
                                           options = pickerOptions(
                                             actionsBox = TRUE, 
                                             size = 10,
                                             selectedTextFormat = "count > 1",
                                           ), 
                                           multiple = TRUE
                                         ),
                                         # selectInput(inputId='nhood',
                                         #             label='NEIGHBOURHOOD',
                                         #             choices=unique_nhood,
                                         #             selected=unique_nhood,
                                         #             multiple=TRUE,
                                         #             selectize=FALSE,
                                         #             size=length(unique_nhood)
                                         #             ),
                                         width=4),
                            # Main area to host the plots
                            mainPanel(
                              # Further split into tabs
                              tabsetPanel(
                                # First tab to host plots
                                tabPanel('Plots',
                                         # Split into 2 x 2 (equal width)
# Crime Map ####################################################################
                                         #fluidRow(
                                           #leafletOutput("CrimeMap", height = "600px")
                                         #),
# Crime Map ####################################################################
                                         fluidRow(
                                           # First row = sample plot 1 and text only
                                           splitLayout(cellWidths = c("50%", "50%"),
                                                       leafletOutput("CrimeMap", height = "600px"),
                                                       plotlyOutput(outputId = 'crime_type_plot'))
                                         ),
                                         fluidRow(
                                           # Second row = text only and sample plot 4
                                           splitLayout(cellWidths = c("50%", "50%"),
                                                       plotlyOutput(outputId = 'crime_neighbourhood_plot'),
                                                       plotlyOutput(outputId = 'crime_hour_plot'))
                                         )
                                ),
                                # Second tab (for illustration only)
                                tabPanel('Extra tab for contingency',
                                         'Use this if we need more space'
                                )
                              )
                            )
                          )
                 ),

                 # Tab 2
                 tabPanel('Learn More', 'Put the instruction / readme here')
)

server <- function(input, output, session) {
  # Sample plot 1
  output$sample <- renderPlotly({
    ggplotly(
      ggplot(mtcars, aes(x=hp, y=mpg)) +
        geom_point(size=1)
    )
  })

  # Plot 2 - Total Crimes by Type
  output$crime_type_plot <- renderPlotly({
    df_select <- df |>
      filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood) |>
      add_count(TYPE)
    
    ggplotly(
      ggplot(df_select, aes(y=reorder(TYPE, -n), fill=TYPE, text=paste0('count: ', n))) +
        geom_bar(stat='count') +
        labs(x='Count',
             y='Crime type',
             title='Number of crimes by type') +
        guides(fill='none'),
      tooltip=c('text')
    )
  })

  # Crime Map ##################################################################
  output$CrimeMap <- renderLeaflet({
    df_select <- df |>
      filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood)
    leaflet(df_select) %>%
      addTiles() %>%
      addMarkers(
        lng = ~ Longtitude,
        lat = ~ Latitude,
        label = ~ paste0(TYPE, " (", HOUR, ":", MINUTE, ")"),
        clusterOptions = markerClusterOptions()
      )
  })
  # Crime Map ##################################################################
  
  # Plot 3 - Total Crimes by Neighbourhood
  output$crime_neighbourhood_plot <- renderPlotly({
    df_select <- df |>
      filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood)
    
    ggplotly(
      ggplot(df_select, aes(x=YEAR, fill=NEIGHBOURHOOD)) +
        geom_area(stat='count') +
        labs(x='Year',
             y='Total number of crimes',
             title='Trend of total number of crimes',
             fill='Neighbourhood')
    )
  })

  # Plot 4 - Total Crimes by Hour
  output$crime_hour_plot <- renderPlotly({
    df_select <- df |>
      filter(YEAR >= input$year[1],
             YEAR <= input$year[2],
             NEIGHBOURHOOD %in% input$nhood)

    df_group <- df_select |>
      group_by(HOUR) |>
      summarise(n = n()) |>
      mutate(Time = as.factor(paste(HOUR, ':00', sep = '')),
             daily_avg = n / (365 * (input$year[2] - input$year[1] + 1)))
    
    df_group$Time = fct_relevel(df_group$Time,
                           c('0:00', '1:00', '2:00', '3:00', '4:00',
                             '5:00', '6:00', '7:00', '8:00', '9:00',
                             '10:00', '11:00', '12:00', '13:00', '14:00',
                             '15:00', '16:00', '17:00', '18:00', '19:00',
                             '20:00', '21:00', '22:00', '23:00')
    )
    
    ggplotly(
      ggplot(df_group, aes(x=Time, y = daily_avg, group = 1)) +
        geom_line() +
        labs(x='Time',
             y='Daily Average',
             title='Average Number of Crimes by Time') +
        scale_x_discrete(breaks=c('0:00', '3:00', '6:00', '9:00',
                                    '12:00', '15:00', '18:00', '21:00'))
    )
  })
  
  # Sample plot 4
  # output$sample4 <- renderPlot({
  #   ggplot(mtcars, aes(x=cyl, y=mpg)) +
  #     geom_point(size=1)
  # })
}

thematic_shiny()
shinyApp(ui, server)