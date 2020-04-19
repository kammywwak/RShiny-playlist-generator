library(tidyverse)
library(spotifyr)
library(httpuv)
library(shiny)
library(shinydashboard)
library(DT)
library(devtools)
# install_github("tiagomendesdantas/Rspotify")
library(Rspotify)

source('data/get_recommendations.r')

shinyServer(
  function(input, output) { 
    
    # Generate playlist as a reactive conductor
    # https://shiny.rstudio.com/articles/reactivity-overview.html
    playlist <- reactive({ 
      gen_rec(artist_string = input$artist_search_string, 
              genre_string = input$genre_search_string, 
              desired_listening_minutes = input$minutes,
              min_date = "1000",
              max_date = "3000")[[1]]
    })
    
    output$trace_table <- renderDataTable({
      
      datatable(options = list(pageLength = -1, lengthChange = FALSE), {
        
        playlist()
        
      })
      
    })
    
    #creating valueBoxOutput content
    
    output$total_track_count <- renderValueBox({
      valueBox(
        playlist() %>% nrow() %>% paste("Tracks"),
        'Total Number of Tracks',
        # ,icon = icon("stats",lib='glyphicon')
        color = "green")
    })
    
    output$total_listening_time <- renderValueBox({
      valueBox(
        formatC(playlist() %>%
                  summarise(sum(duration_ms)/60000)
                , format="d", big.mark=',') %>% paste("Minutes"),
        'Total Listening Time',
        # ,icon = icon("stats",lib='glyphicon')
        color = "yellow")
    })
    
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
      filename = function() {
        paste0("playlist-", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(playlist(), file, row.names = FALSE)
      }
    )
  }
)