#' Function to upload a new XLSForm to KoboToolbox.
#'
#' @param server_id The base Kobo URL (without https://).
#' @param xlsform_path The local path to the XLSForm.
#' @param api_token The API token used to authorize the request.
#' @param description Optional description text.
#' @param country_name Optional human-readable country label (e.g., "Algeria").
#' @param country_code Optional ISO 3-letter country code (e.g., "DZA").
#' @param sector Optional sector label (e.g., "Educational Services / Higher Education").
#' @param form_name The name to assign to the survey in Kobo (optional).
#' @param max_attempts The number of times to fetch asset.
#' @return Parsed response (list) from Kobo API with form metadata.
#' @export
upload_xlsform = function(server_id, xlsform_path, api_token, description = NULL, 
                          country_name = NULL, country_code = NULL, 
                          sector = NULL, form_name = NULL, max_attempts=180) {
  
###################################################### Step 0: Set defaults for meta-data
 if(is.null(description)) description = "Uploaded with XLSFormulatoR"
 if(is.null(country_name)) country_name = "Algeria"
 if(is.null(country_code)) country_code = "DZA"
 if(is.null(sector)) sector = "Educational Services / Higher Education"
 if(is.null(form_name)) form_name = "NetCollect"
  
 server_url = paste0("https://", server_id)

########################################################## Step 1: Post new blank survey
 creation_url = paste0(server_url, "/api/v2/assets/")

 create_survey = POST(
  url = creation_url,
  add_headers(
    Authorization = paste("Token", api_token),
    `Content-Type` = "application/json"
  ),
  body = toJSON(list(
    name = form_name,
    asset_type = "survey"
  ), auto_unbox = TRUE)
 )

# Inspect response
status_code(create_survey)
survey_asset = content(create_survey, as = "parsed", encoding = "UTF-8")
print("Step 1: New blank survey created.")

######################################### Step 2: Import XLSForm into the blank survey
 import_url = paste0(server_url, "/api/v2/imports/")

 import_survey = POST(
  import_url,
  add_headers(Authorization = paste("Token", api_token)),
  body = list(
    file = upload_file(xlsform_path),
    destination = paste0(server_url,"/api/v2/assets/", survey_asset$uid, "/")
  ),
  encode = "multipart"
 )

 import_task = content(import_survey, as = "parsed")
 task_uid = import_task$uid
 print("Step 2: Survey import started.")
  
############################################ Step 3: Poll for completion
 attempt = 0
 status = NULL

 while(is.null(status) || status != "complete"){
  Sys.sleep(2)
  attempt = attempt + 1

  check_import = GET(
    paste0(server_url, "/api/v2/imports/", task_uid, "/"),
    add_headers(Authorization = paste("Token", api_token))
  )

  # Gracefully handle non-200 responses
  if(status_code(check_import) != 200){
    warning("Received status ", status_code(check_import), " from import check.")
    next
  }

  res = content(check_import, as = "parsed", encoding = "UTF-8")
  status = res$status

  cat("Attempt", attempt, "- Status:", status, "\n")

  # Safety stop after too many attempts
  if(attempt >= max_attempts){
    stop("Import check timed out after ", max_attempts * 2, " seconds.")
  }
 }

 survey_uid = res$messages$updated[[1]]$uid
 print(paste0("Step 3: Import succeeded. Scraped the new asset uid: ", survey_uid))

################################################ Step 4: Update the asset with settings
 asset_url = paste0(server_url, "/api/v2/assets/", survey_uid, "/")

 settings = list(
  sector = list(label = sector, value = sector),
  country = list(list(label = country_name, value = country_code)),
  country_codes = list(country_code),
  description = description
  )
  
 update_body = list(
  settings = settings
 )
  
 update_response = httr::PATCH(
  url = asset_url,
   httr::add_headers(
    Authorization = paste("Token", api_token),
    `Content-Type` = "application/json"
    ),
    body = jsonlite::toJSON(update_body, auto_unbox = TRUE)
  )
  
 if(httr::status_code(update_response) == 200){
  asset = httr::content(update_response, as = "parsed", encoding = "UTF-8")
  message("Settings updated successfully")
  } else {
  message("Settings update status: ", httr::status_code(update_response))
  }

 print("Step 4: Added required settings to the new survey.")

#################################### Step 5: First deploy
 deploy_url = paste0(server_url, "/api/v2/assets/", survey_uid, "/deployment/")

 # Deploy the asset
 response = POST(
  deploy_url,
  add_headers(Authorization = paste("Token", api_token))
 )

 # Check the result
 status_code(response)
 print("Step 5: Survey deployed to archive.")

####################################### Step 6: Now redeploy to live
 body = jsonlite::toJSON(list(
             active = TRUE,
             archived = FALSE,
             asset_type = "survey"
             ), auto_unbox = TRUE)
 
 response = httr::PATCH(
             url = deploy_url,
             httr::add_headers(Authorization = paste("Token", api_token),
               "Content-Type" = "application/json"),
             body = body,
             encode = "json")

 print("Step 6: Survey is live.")

   return(invisible(asset))
}








