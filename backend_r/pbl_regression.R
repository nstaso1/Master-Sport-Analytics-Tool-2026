library(plumber)
library(jsonlite)

db_file <- "mystics_db.json"

init_db <- function() {
  if (!file.exists(db_file)) {
    write_json(list(masterDB = list(), boards = list()), db_file, auto_unbox = TRUE)
  }
}

#* @filter cors
function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  plumber::forward()
}

#* @get /api/database
function() {
  init_db()
  read_json(db_file)
}

#* @post /api/database
function(req, res) {
  data <- jsonlite::fromJSON(req$postBody, simplifyVector = FALSE)
  write_json(data, db_file, auto_unbox = TRUE)
  list(status = "success", message = "Database saved.")
}
