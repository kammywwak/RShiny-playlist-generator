library(shiny)
library(shinydashboard)
library(DT)
library(shinyWidgets)

genre <- c(
  "acoustic",
  "afrobeat",
  "alt-rock",
  "alternative",
  "ambient",
  "anime",
  "black-metal",
  "bluegrass",
  "blues",
  "bossanova",
  "brazil",
  "breakbeat",
  "british",
  "cantopop",
  "chicago-house",
  "children",
  "chill",
  "classical",
  "club",
  "comedy",
  "country",
  "dance",
  "dancehall",
  "death-metal",
  "deep-house",
  "detroit-techno",
  "disco",
  "disney",
  "drum-and-bass",
  "dub",
  "dubstep",
  "edm",
  "electro",
  "electronic",
  "emo",
  "folk",
  "forro",
  "french",
  "funk",
  "garage",
  "german",
  "gospel",
  "goth",
  "grindcore",
  "groove",
  "grunge",
  "guitar",
  "happy",
  "hard-rock",
  "hardcore",
  "hardstyle",
  "heavy-metal",
  "hip-hop",
  "holidays",
  "honky-tonk",
  "house",
  "idm",
  "indian",
  "indie",
  "indie-pop",
  "industrial",
  "iranian",
  "j-dance",
  "j-idol",
  "j-pop",
  "j-rock",
  "jazz",
  "k-pop",
  "kids",
  "latin",
  "latino",
  "malay",
  "mandopop",
  "metal",
  "metal-misc",
  "metalcore",
  "minimal-techno",
  "movies",
  "mpb",
  "new-age",
  "new-release",
  "opera",
  "pagode",
  "party",
  "philippines-opm",
  "piano",
  "pop",
  "pop-film",
  "post-dubstep",
  "power-pop",
  "progressive-house",
  "psych-rock",
  "punk",
  "punk-rock",
  "r-n-b",
  "rainy-day",
  "reggae",
  "reggaeton",
  "road-trip",
  "rock",
  "rock-n-roll",
  "rockabilly",
  "romance",
  "sad",
  "salsa",
  "samba",
  "sertanejo",
  "show-tunes",
  "singer-songwriter",
  "ska",
  "sleep",
  "songwriter",
  "soul",
  "soundtracks",
  "spanish",
  "study",
  "summer",
  "swedish",
  "synth-pop",
  "tango",
  "techno",
  "trance",
  "trip-hop",
  "turkish",
  "work-out",
  "world-music"
)

shinyUI(
  dashboardPage(
    dashboardHeader(title = "Playlist Generator"),
    dashboardSidebar(
      
      # Artist name input
      textInput("artist_search_string", label = h3("Artist(s)"), value = "rhye|bonobo")
      
      # Genre inputs
      , shinyWidgets::pickerInput(
        inputId = "genre_drop_down",
        label = h3("Genre(s)"),
        choices = genre,
        selected = "house",
        options = list(`actions-box` = TRUE),
        multiple = TRUE
      )
      
      # Min year
      , textInput("min_year", label = h3("Begin in year..."), value = "1980")
      
      # Max year
      , textInput("max_year", label = h3("End in year..."), value = "")
      
      # desired listening minutes input
      , numericInput("minutes", label = h3("Desired Listening Minutes"), value = 120)
      
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