#' Function to upload a new XLSForm to KoboToolbox.
#'
#' @param url The base Kobo API URL.
#' @param xlsform_path The local path to the XLSForm.
#' @param api_token The API token used to authorize the request.
#' @param form_name The name to assign to the survey in Kobo (optional).
#' @return Parsed response (list) from Kobo API with form metadata.
#' @export
upload_xlsform = function(url, xlsform_path, api_token, form_name = NULL) {
  # Payload and file
  api_url = paste0("https://", url, "/api/v2/assets/")
  payload = list(filename = basename(xlsform_path))
  files = list(xls_file = httr::upload_file(xlsform_path))
  
  # Metadata
  data = list(
    description = "Uploaded XLSForm",
    metadata = jsonlite::toJSON(payload),
    asset_type = "survey"
  )
  
  # Add form name if provided
  if (!is.null(form_name)) {
    data$name = form_name
  }

  # Combine into request body
  body = c(files, data)
  
  # POST request
  response = httr::POST(
    url = api_url,
    httr::add_headers(Authorization = paste("Token", api_token)),
    body = body,
    encode = "multipart"
  )
  
  # Check response
  if (httr::status_code(response) == 201) {
    message("XLSForm upload successful: ", basename(xlsform_path))
  } else {
    message("Upload failed: ", basename(xlsform_path))
    message("Server response: ", httr::content(response, "text"))
  }
  
  # Return content (parsed JSON)
   invisible(httr::content(response, as = "parsed", encoding = "UTF-8"))
}
