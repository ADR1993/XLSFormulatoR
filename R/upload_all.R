#' Function to delete ALL attached files in a project (caution advised).
#'
#' @param media_url The url for the media files on Kobo.
#' @param media_folder The local path to the media file folder.
#' @param media_files The names of the media files.
#' @param api_token The token used to sign the request.
#' @param wait_time The waitime between requests.
#' @param overwrite If TRUE, then deletes and reuploads existing files.
#' @return This just pushes files. No return. 
#' @export

upload_all = function(media_url, media_folder, media_files, api_token, wait_time = 0.1, overwrite = FALSE){
  if(overwrite == TRUE){
    # Delete files with the same name from the project
    spsUtil::quiet(delete_files(media_url, media_files, api_token)) 
    
    # Upload everything
    for(file in media_files){
      Sys.sleep(wait_time)
      upload_media(media_url, paste0(media_folder, "/", file), api_token)
    }
  }
  
  # This only uploads files which do not already exists in the project
  if(overwrite == FALSE){
    # retrieve the media objects in the project
    media_df = retrieve_media(media_url, api_token)
    
    # Extract a vector of filenames which are present in the local folder, but not in the project
    media_to_upload = media_files[!(media_files %in% media_df$filename)]
    
    # Upload if the vector of media to upload is nonnull
    if(length(media_to_upload) > 0){
      for(file in media_to_upload){
        Sys.sleep(wait_time)
        upload_media(media_url, paste0(media_folder, "/", file), api_token)
      }
    }else{
      message("No file to upload")
    }
  }
}
