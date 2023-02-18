library(shiny)
library(ggplot2)
library(bslib)
library(thematic)
library(plotly)

ui <- navbarPage('Vancouver Crime Data',
                 # Use a theme
                 theme = bslib::bs_theme(bootswatch = 'solar'),
                 
                 # Tab 1
                 tabPanel('Main',
                          # Side area to host the controls
                          sidebarLayout( 
                                         # Sample code for slider (range)
                            sidebarPanel(sliderInput(inputId='year',
                                                     label='YEAR:',
                                                     min=2003,
                                                     max=2022,
                                                     value=c(2003, 2022),
                                                     sep=''),
                                         # Sample code for selection box (multiple)
                                         selectInput(inputId='nhood',
                                                     label='NEIGHBOURHOOD',
                                                     choices=c('Arbutus Ridge'='AR',
                                                               'Central Business District'='CBD',
                                                               'Dunbar-Southlands'='DS'),
                                                     selected=c('AR', 'CBD', 'DS'),
                                                     multiple=TRUE)),
                            # Main area to host the plots
                            mainPanel(
                              # Further split into tabs
                              tabsetPanel(
                                # First tab to host plots
                                tabPanel('Plots',
                                         'Put our plots here',
                                         # Split into 2 x 2 (equal width)
                                         fluidRow(
                                           # First row = sample plot 1 and text only
                                           splitLayout(cellWidths = c("50%", "50%"), plotlyOutput(outputId = 'sample'), 'PLOT2 HERE')
                                         ),
                                         fluidRow(
                                           # Second row = text only and sample plot 4
                                           splitLayout(cellWidths = c("50%", "50%"), 'PLOT3 HERE', plotOutput(outputId = 'sample4'))
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
  
  # Sample plot 4
  output$sample4 <- renderPlot({
    ggplot(mtcars, aes(x=cyl, y=mpg)) +
      geom_point(size=1)
  })
}

shinyApp(ui, server)