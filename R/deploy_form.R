#' Function to deploy or redeploy a KoboToolbox form via API
#'
#' @param api_url The base Kobo API URL (e.g. "https://kf.kobotoolbox.org/api/v2/assets/").
#' @param asset_id The UID of the form (asset) to deploy or redeploy.
#' @param api_token Your Kobo API token.
#' @param redeploy Logical; if TRUE, redeploy (unarchive) instead of first deploy.
#' @return TRUE if deployment successful, FALSE otherwise.
#' @export

deploy_form = function(api_url, asset_id, api_token, redeploy = FALSE) {
  if(!redeploy) {
    deploy_url = paste0(api_url, asset_id, "/deployment/")
    
    response = httr::POST(
      url = deploy_url,
      httr::add_headers(
        Authorization = paste("Token", api_token),
        "Content-Type" = "application/json"
      ),
      body = "{}"
    )
  }else{
    body = jsonlite::toJSON(list(
             active = TRUE,
             archived = FALSE,
             asset_type = "survey"
             ), auto_unbox = TRUE)
 
      response = httr::PATCH(
             url = paste0(api_url, asset_id, "/deployment/"),
             httr::add_headers(Authorization = paste("Token", api_token),
               "Content-Type" = "application/json"),
             body = body,
             encode = "json")
  }
  
  # ---- Check response ----
  if (httr::status_code(response) %in% c(200, 201)) {
    action = ifelse(redeploy, "Redeployed", "Deployed")
    message("Form ", action, " successfully: ", asset_id)
    return(TRUE)
  } else {
    message("Deployment failed for: ", asset_id)
    message("Server response: ", httr::content(response, "text"))
    return(FALSE)
  }
}

