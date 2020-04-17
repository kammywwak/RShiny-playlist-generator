library(tidyverse)
library(spotifyr)
library(httpuv)
library(devtools)
# install_github("tiagomendesdantas/Rspotify")
library(Rspotify)

# --- Spotify API Keys ---

keys <- spotifyOAuth(app_id = 'playlist-generator-test',
                     client_id = Sys.getenv("SPOTIFY_CLIENT_ID"),
                     client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"))

# ---- Define Functions ---- 
SearchArtist <- function(search_term){
  
  searchArtist(search_term, token = keys) %>% 
    filter(followers == max(followers)) %>% 
    rename(name = display_name)
  
}

compile_recommendations <- function(artist_id = NULL, genre_name = NULL){
  
  desired_track_count <- 100
  
  get_recommendations(seed_artists = artist_id,
                      seed_genres = genre_name,
                      limit = desired_track_count, 
                      authorization = get_spotify_access_token())  
}

extract_artist_name <- function(artist_df){
  
  artist_df %>% 
    summarise(artist_name = name %>% 
                unique() %>% 
                sort() %>% 
                toString())
  
}

gen_rec <- function(artist_string = NULL, genre_string = NULL, desired_listening_minutes = 120){
  
  if(!is.null(artist_string))
    
  {
    
    artist_input <- str_split(artist_string, "\\|") %>% unlist() 
    
    n_rerun <- ceiling(desired_listening_minutes/(300*length(artist_input)))
    
    seed_artists <- lapply(X = artist_input, FUN = SearchArtist) %>% 
      bind_rows()
    
    seed_artist_id <- seed_artists$id %>% rep(n_rerun )
    
    genre_input <- str_split(genre_string, "\\|") %>% 
      unlist() %>% 
      list() %>% 
      rep(seed_artist_id %>% length())
    
    rec_df <- mapply(FUN=compile_recommendations,
                     artist_id = seed_artist_id,
                     genre_name = genre_input,
                     SIMPLIFY = F) %>%
      bind_rows() %>%
      select(artists, duration_ms, explicit,
             is_local, name, external_ids.isrc, popularity, track_number,
             type, uri, album.name,
             album.id, album.release_date,
             album.uri)
    
  }
  
  else{
    
    n_rerun <- ceiling(desired_listening_minutes/300)
    
    dummy_artist_input <- NULL %>% list() %>% rep(n_rerun)
    
    genre_input <- str_split(genre_string, "\\|") %>% 
      unlist() %>% 
      list() %>% 
      rep(n_rerun)
    
    rec_df <- mapply(FUN=compile_recommendations,
                     artist_id = dummy_artist_input,
                     genre_name = genre_input,
                     SIMPLIFY = F) %>%
      bind_rows() %>%
      select(artists, duration_ms, explicit,
             is_local, name, external_ids.isrc, popularity, track_number,
             type, uri, album.name,
             album.id, album.release_date,
             album.uri)
  }
  
  artists <- lapply(FUN = extract_artist_name, X = rec_df$artists) %>%
    bind_rows()
  
  deduped_rec <- artists %>%
    bind_cols(rec_df) %>%
    select(-artists) %>%
    group_by_all() %>%
    add_tally() %>%
    ungroup() %>%
    rename(appearances = n) %>%
    distinct()
  
  # keep tracks with more than 1 appearances
  hits <- deduped_rec %>%
    filter(appearances > 1)
  
  # randomize list
  set.seed(2020)
  
  rows <- sample(nrow(deduped_rec))
  
  shuffled_rec <- deduped_rec[rows,] %>%
    # calculate cumulative listening time
    mutate(cumulative_minutes = cumsum(duration_ms/60000)) %>%
    # filter to the desired total listening time
    filter(cumulative_minutes <= desired_listening_minutes) %>%
    select(artist_name, name, album.name,
           album.release_date, appearances, popularity, external_ids.isrc,
           everything())
  
  
  missing_hits <- hits %>%
    anti_join(shuffled_rec)
  
  list(shuffled_rec, missing_hits)
  
}



