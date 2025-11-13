#' Function to deploy a new XLSForm to KoboToolbox.
#'
#' @param url The base Kobo URL (without https://).
#' @param block_uid The uid of the block template.
#' @param api_token The API token used to authorize the request.
#' @param deploy Deploy the survey.
#' @return Parsed response (list) from Kobo API with form metadata.
#' @export

convert_block_to_survey = function(url, block_uid, api_token, deploy = TRUE) {
  block_url = paste0("https://", url, "/api/v2/assets/", block_uid, "/")

  get_response = httr::GET(
    url = block_url,
    httr::add_headers(Authorization = paste("Token", api_token))
  )

  if(httr::status_code(get_response) != 200) {
    stop("Failed to retrieve block asset. Status: ", httr::status_code(get_response))
  }

  block_asset = httr::content(get_response, as = "parsed", encoding = "UTF-8")

  if(block_asset$asset_type != "block"){
    stop("The provided UID is not a 'block' asset. Found: ", block_asset$asset_type)
  }

  message("Creating new survey asset...")

  # Construct new survey body
  new_asset_body = list(
    name = block_asset$name,
    asset_type = "survey",
    content = block_asset$content,
    settings = block_asset$settings
  )

  create_response = httr::POST(
    url = paste0("https://", url, "/api/v2/assets/"),
    httr::add_headers(
      Authorization = paste("Token", api_token),
      `Content-Type` = "application/json"
    ),
    body = jsonlite::toJSON(new_asset_body, auto_unbox = TRUE)
  )

  if(!httr::status_code(create_response) %in% c(200, 201)) {
    message("Failed to create new survey asset.")
    message("Status code: ", httr::status_code(create_response))
    message("Response: ", httr::content(create_response, "text", encoding = "UTF-8"))
    stop("Survey creation failed.")
  }

  survey_asset = httr::content(create_response, as = "parsed", encoding = "UTF-8")
  survey_uid = survey_asset$uid

  message("New survey created successfully. UID: ", survey_uid)

  # Optional deployment
  if(deploy){
    deploy_url = paste0("https://", url, "/api/v2/assets/", survey_uid, "/deployment/")
    deploy_body = list(active = TRUE)

    deploy_response = httr::POST(
      url = deploy_url,
      httr::add_headers(
        Authorization = paste("Token", api_token),
        `Content-Type` = "application/json"
      ),
      body = jsonlite::toJSON(deploy_body, auto_unbox = TRUE)
    )

    if(httr::status_code(deploy_response) %in% c(200, 201)) {
      message("Survey deployed successfully!")
    } else{
      warning("Survey created but deployment failed. You can deploy it manually.")
    }
  }

  return(invisible(list(
    old_block_uid = block_uid,
    new_survey_uid = survey_uid,
    survey_asset = survey_asset
  )))
}






