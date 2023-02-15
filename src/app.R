library(shiny)
library(ggplot2)
library(bslib)
library(thematic)
library(plotly)

ui <- navbarPage('Vancouver Crime Data',
                 theme = bslib::bs_theme(bootswatch = 'solar'),
                 tabPanel('Main',
                          sidebarLayout( 
                            sidebarPanel(sliderInput(inputId='year',
                                                     label='YEAR:',
                                                     min=2003,
                                                     max=2022,
                                                     value=c(2003, 2022),
                                                     sep=''),
                                         selectInput(inputId='nhood',
                                                     label='NEIGHBOURHOOD',
                                                     choices=c('Arbutus Ridge'='AR',
                                                               'Central Business District'='CBD',
                                                               'Dunbar-Southlands'='DS'),
                                                     selected=c('AR', 'CBD', 'DS'),
                                                     multiple=TRUE)),
                            mainPanel(
                              tabsetPanel(
                                tabPanel('Plots',
                                         'Put our plots here',
                                         fluidRow(
                                           splitLayout(cellWidths = c("50%", "50%"), plotlyOutput(outputId = 'sample'), 'PLOT2 HERE')
                                         ),
                                         fluidRow(
                                           splitLayout(cellWidths = c("50%", "50%"), 'PLOT3 HERE', plotOutput(outputId = 'sample4'))
                                         )
                                ),
                                tabPanel('Extra tab for contingency',
                                         'Use this if we need more space'
                                )
                              )
                            )
                          )
                 ),
                 tabPanel('Learn More', 'Put the instruction / readme here')
)

server <- function(input, output, session) {
  output$sample <- renderPlotly({
    ggplotly(
      ggplot(mtcars, aes(x=hp, y=mpg)) +
        geom_point(size=1)
    )
  })
  
  output$sample4 <- renderPlot({
    ggplot(mtcars, aes(x=cyl, y=mpg)) +
      geom_point(size=1)
  })
}

shinyApp(ui, server)