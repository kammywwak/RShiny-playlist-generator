library(shiny)
library(shinydashboard)
library(DT)

shinyUI(
  dashboardPage(
    dashboardHeader(title = "Playlist Generator"),
    dashboardSidebar(
      
      # Artist name input
      textInput("artist_search_string", label = h3("Artist(s)"), value = "bonobo|grimes")
      
      # Genre name input
      , textInput("genre_search_string", label = h3("Genre(s)"), value = "chill")
      
      # Min year
      , textInput("min_year", label = h3("Begin in year..."), value = "1000")
      
      # Max year
      , textInput("max_year", label = h3("End in year..."), value = "3000")
      
      # desired listening minutes input
      , numericInput("minutes", label = h3("Desired Listening Minutes"), value = 6*60)
      
    ),
    
    dashboardBody(
      # Button
      downloadButton("downloadData", "Download")
      
      , fluidRow(
        valueBoxOutput("total_track_count"),
        valueBoxOutput("total_listening_time"))
      
      , DT::dataTableOutput("trace_table")
      
    )
  )
)