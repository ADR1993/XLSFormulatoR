#' Function to create a data export file.
#'
#' @param export_url The url for the export on Kobo.
#' @param api_token The token used to sign the request.
#' @return This just pushes file. No return. 
#' @export

create_export = function(export_url, api_token){
  body = list(fields_from_all_versions = "true",
            hierarchy_in_labels = "false",
            group_sep = "/",
            lang = "_xml",
            type = "xls",
            multiple_select = "both",
            include_media_url = "true"
             )
  
  # POST request
  response = httr::POST(export_url, 
             httr::add_headers(Authorization = paste("Token", api_token)),
             body = body)
  
  # Output
  if(status_code(response) == 201){
    
    message(paste0("Export creation successful (status code ", httr::status_code(response), ")"))
    
    export_loc = response$all_headers[[1]]$headers$location # Location of the export instance
    return(export_loc)
    
  } else{
    message(paste0("Export creation failed: error ", httr::status_code(response)))
  }
}
