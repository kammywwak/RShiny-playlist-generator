library(tidyverse)
library(spotifyr)
library(httpuv)
library(shiny)
library(shinydashboard)
library(DT)
library(devtools)
library(Rspotify)
library(shinyWidgets)

source('data/get_recommendations.r')

shinyServer(
  function(input, output) { 
    
    # Generate playlist as a reactive conductor
    # https://shiny.rstudio.com/articles/reactivity-overview.html
    playlist <- reactive({
      
      gen_rec(artist_string = input$artist_search_string,
              genre_string = input$genre_drop_down,
              desired_listening_minutes = input$minutes,
              min_date = input$min_year,
              max_date = input$max_year)[[1]] %>%
        # create hyperlinks
        mutate(external_urls.spotify = paste0("<a href='", external_urls.spotify,"' target='_blank'>", external_urls.spotify,"</a>"))
    })
    
    output$trace_table <- renderDataTable({
      
      datatable(options = list(pageLength = -1, lengthChange = FALSE), {
        
        playlist()
        
      },
      
      escape = FALSE)
      
    })
    
    #creating valueBoxOutput content
    
    output$total_track_count <- renderValueBox({
      valueBox(
        playlist() %>% nrow() %>% paste("Tracks"),
        'Total Number of Tracks',
        color = "green")
    })
    
    output$total_listening_time <- renderValueBox({
      valueBox(
        prettyunits::pretty_ms(playlist() %>% summarise(sum(duration_ms)) %>% first()),
        'Total Listening Time',
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