#' Function that lists media files associated with a project.
#'
#' @param url The Kobo server url.
#' @param asset_id The asset.
#' @return A data.frame listing the saved objects. 
#' @export

make_kobo_urls = function(url, asset_id){
 api_url = paste0("https://", url, "/api/v2/assets/")                                           # Base API URL
 media_url = paste0("https://", url, "/api/v2/assets/", asset_id, "/files/")                    # URL for media upload
 deployment_url = paste0("https://kf.kobotoolbox.org/api/v2/assets/", asset_id, "/deployment/") # URL for form deployment
 base_url = paste0("https://kf.kobotoolbox.org/api/v2/assets/", asset_id, "/")                  # Base URL for the project
 replace_form_url = paste0("https://kf.kobotoolbox.org/api/v2/imports/", asset_id, "/")
 export_url = paste0("https://kf.kobotoolbox.org/api/v2/assets/", asset_id, "/exports/")
 return(list(api_url = api_url,
             media_url = media_url, 
             deployment_url = deployment_url, 
             base_url = base_url, 
             replace_form_url = replace_form_url,
             export_url = export_url
 ))
}
