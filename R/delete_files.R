#' Function to delete files that are present in the media_files vector.
#'
#' @param media_url The url for the media files on Kobo.
#' @param media_files The names of media files on Kobo.
#' @param api_token The token used to sign the request.
#' @return This just deletes files. No return. 
#' @export

delete_files = function(media_url, media_files, api_token){
  headers = httr::add_headers(Authorization = paste("Token", api_token)) 
  
  # Retrieve media files from the project
  media_df = retrieve_media(media_url, api_token)
  
  # Loop and delete
  if(is.null(media_df) == FALSE){
    
    for(i in 1:nrow(media_df)){
      if(media_df$filename[i] %in% media_files){
        delete_url = paste0(media_url, media_df$uid[i], "/")
        delete_response = httr::DELETE(delete_url, headers)
        message(paste("Deleted:", media_df$filename[i], "- Status code", delete_response$status_code))
      }
    }
  } 
}
