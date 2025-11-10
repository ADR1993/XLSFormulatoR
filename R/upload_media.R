#' Function to upload a single media file.
#'
#' @param media_url The url for the media files on Kobo.
#' @param file_path The local path to the media file.
#' @param api_token The token used to sign the request.
#' @return This just pushes file. No return. 
#' @export

upload_media = function(media_url, file_path, api_token){
  # Set payload
  payload = list(filename = basename(file_path))
  
  # Set files
  files = list(content = httr::upload_file(file_path))
  
  # Set data
  data = list(
    description = "Input file",
    metadata = jsonlite::toJSON(payload),
    file_type = "form_media"
  )
  
  # Data to store
  body = c(files, data)
  
  # POST request
  response = httr::POST(
    media_url,
    httr::add_headers(Authorization = paste("Token", api_token)),
    body = body
  )
  
  # Message
  if(httr::status_code(response) == 201){
    message("Upload successful: ", file_path)
  }else{
    message("Upload failed: ", file_path, " - ", httr::content(response, "text"))
  }
}
