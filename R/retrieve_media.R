#' Function that lists media files associated with a project.
#'
#' @param media_url The url for the media files on Kobo.
#' @param api_token The token used to sign the request.
#' @return A data.frame listing the saved objects. 
#' @export

retrieve_media = function(media_url, api_token){
  # Get request
  response = httr::GET(
    media_url,
    httr::add_headers(Authorization = paste("Token", api_token))
  )
  
  # Return list of media files in the project
  if(httr::status_code(response) == 200) {
    media_list = httr::content(response, "parsed")
  }else{
    message("Failed to retrieve media list: ", httr::content(response, "text"))
  }
  
  # Loop to extract information on files
  ls = vector(mode = "list", length = length(media_list$results))
  
  if(length(media_list$results) > 0){
    for(i in 1:length(media_list$results)){
      ls[[i]]$uid = media_list$results[[i]]$uid                    # Extract unique file ID
      ls[[i]]$filename = media_list$results[[i]]$metadata$filename # Extract filename
      ls[[i]]$type = media_list$results[[i]]$metadata$mimetype     # Extract file type info
      }
    
    df = data.frame(do.call(rbind, ls)) # Bind it together
    df = lapply(df, as.character)       # Convert columns to character class
    df = data.frame(df)                 # Convert it to dataframe
    return(df)
    } else {
    message("No media associated with this form ID")
  }
}
