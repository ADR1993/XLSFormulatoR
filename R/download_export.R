#' Function to download a data file.
#'
#' @param export_url The url for the export on Kobo.
#' @param folder_path The path to save a file to.
#' @param api_token The token used to sign the request.
#' @param overwrite Allow overwriting?.
#' @return This just pushes file. No return. 
#' @export

download_export = function(export_url, folder_path, api_token, overwrite = FALSE){
  # Send a GET request with the export instance URL to retrieve the URL of the actual data file
  # Sleepy sleepy
  print("Preparing your data!")
  Sys.sleep(7)

  query = httr::GET(url = export_url, 
      httr::add_headers(Authorization = paste("Token", api_token)))
  query2 = httr::content(query, "parsed")
  data_loc = query2$result # This is the URL of the data file
  
  # Create filename from data location. It will include form ID and export ID
  if(is.null(data_loc) == TRUE){
    stop("Data location is empty. Try to re-run the code.")
  }
  
  a = strsplit(data_loc, split = "/") 
  b = unlist(a) 
  filename = utils::tail(b, n = 1)
  
  # Create filepath
  filepath = paste0(folder_path, "/", filename)

  # Perform GET request
  res = httr::GET(url = data_loc,
      httr::add_headers(Authorization = paste("Token", api_token)),
      httr::write_disk(filepath, overwrite = overwrite))
  
  if(httr::status_code(res) == 200){
    message("Download successful (status code ", httr::status_code(res), ")")
    print(filepath)
  } else {
    message("Download failed. Status code ", httr::status_code(res))
  }
}

