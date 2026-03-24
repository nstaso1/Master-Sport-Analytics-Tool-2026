# Required Packages
# install.packages(c("shiny", "bslib", "httr", "jsonlite", "dplyr"))

library(shiny)
library(bslib)
library(httr)
library(jsonlite)
library(dplyr)

# ==========================================
# CONFIGURATION
# ==========================================
# Replace this with your exact Firebase Realtime Database URL
# IMPORTANT: It must end with a trailing slash!
FIREBASE_URL <- "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com/"

# ==========================================
# UI ARCHITECTURE
# ==========================================
ui <- page_navbar(
  theme = bs_theme(version = 5, bootswatch = "darkly", primary = "#ffae00"),
  title = "Omni-Sport Front Office",
  
  nav_panel("🔴 Global Live Monitors",
            fluidRow(
              column(4, card(
                card_header("Football Playoff Monitor", class = "bg-primary"),
                uiOutput("cfb_live_ui")
              )),
              column(4, card(
                card_header("Hoops Tournament Monitor", class = "bg-warning text-dark"),
                uiOutput("bkb_live_ui")
              )),
              column(4, card(
                card_header("System Health", class = "bg-dark border-secondary"),
                textOutput("sys_status"),
                hr(),
                p("This dashboard polls Firebase every 5 seconds. It automatically receives updates from the HTML iPad interface and the Python data pipeline.", class = "text-muted small")
              ))
            )
  ),
  
  nav_panel("📋 Master Recruiting Boards",
            fluidRow(
              column(12, 
                     card(
                       card_header("D1 College Football (CFB)"),
                       tableOutput("cfb_d1_board")
                     )
              )
            ),
            fluidRow(
              column(6, 
                     card(
                       card_header("D1 College Basketball (BKB)"),
                       tableOutput("bkb_d1_board")
                     )
              ),
              column(6, 
                     card(
                       card_header("D1 College Baseball (BSB)"),
                       tableOutput("bsb_d1_board")
                     )
              )
            )
  )
)

# ==========================================
# SERVER LOGIC
# ==========================================
server <- function(input, output, session) {
  
  # ---------------------------------------------------------
  # 1. CLOUD POLLING (5-second intervals)
  # ---------------------------------------------------------
  cloud_data <- reactivePoll(5000, session,
                             checkFunc = function() { Sys.time() },
                             valueFunc = function() {
                               res <- GET(paste0(FIREBASE_URL, ".json"))
                               if(status_code(res) == 200) {
                                 return(fromJSON(rawToChar(res$content)))
                               } else { 
                                 return(NULL) 
                               }
                             }
  )
  
  output$sys_status <- renderText({
    paste("Last successful cloud ping:", format(Sys.time(), "%H:%M:%S"))
  })
  
  # ---------------------------------------------------------
  # 2. RENDER MASTER RECRUITING BOARDS
  # ---------------------------------------------------------
  parse_board <- function(board_data) {
    if(is.null(board_data) || length(board_data) == 0) return(data.frame(Message = "No players found."))
    df <- bind_rows(lapply(board_data, as.data.frame))
    df <- df %>% 
      select(name, pos, p1, p2, score, timestamp) %>%
      arrange(desc(score)) %>%
      rename(Name = name, Position = pos, `Metric 1` = p1, `Metric 2` = p2, `Overall Grade` = score, Logged = timestamp)
    return(df)
  }
  
  output$cfb_d1_board <- renderTable({ parse_board(cloud_data()$boards$d1$cfb) })
  output$bkb_d1_board <- renderTable({ parse_board(cloud_data()$boards$d1$bkb) })
  output$bsb_d1_board <- renderTable({ parse_board(cloud_data()$boards$d1$bsb) })
  
  # ---------------------------------------------------------
  # 3. RENDER LIVE GAME MONITORS
  # ---------------------------------------------------------
  render_live_feed <- function(data) {
    if(is.null(data)) return(HTML("<p class='text-muted'>Awaiting Python Pipeline Sync...</p>"))
    
    HTML(paste0(
      "<h3 class='text-center'>", data$awayTeam, " ", data$awayScore, " @ ", data$homeTeam, " ", data$homeScore, "</h3>",
      "<hr><p class='text-center text-muted'>Status: ", data$status, "</p>",
      "<p class='text-center small'>Last Updated: ", data$lastUpdated, "</p>"
    ))
  }
  
  output$cfb_live_ui <- renderUI({ render_live_feed(cloud_data()$live_games$d1$cfb_global) })
  output$bkb_live_ui <- renderUI({ render_live_feed(cloud_data()$live_games$d1$bkb_global) })
}

shinyApp(ui, server)
