#' Function to delete ALL attached files in a project (caution advised).
#'
#' @param media_url The url for the media files on Kobo.
#' @param api_token The token used to sign the request.
#' @return This just deletes files. No return. 
#' @export

delete_all_files = function(media_url, api_token){
  # Authorization
  headers = httr::add_headers(Authorization = paste("Token", api_token)) 
  
  # Retrieve files
  media_df = retrieve_media(media_url, api_token)
  
  # Loop delete all files in the project
  for(i in 1:nrow(media_df)){
    delete_url = paste0(media_url, media_df$uid[i], "/")
    delete_response = httr::DELETE(delete_url, headers)
    message(paste("Deleted:", media_df$filename[i], "- Status code", delete_response$status_code))
  }
}
