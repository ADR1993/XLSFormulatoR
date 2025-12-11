#' Function to get a Kobo token.
#'
#' @param server_id The url for the base server on Kobo (no https://).
#' @param username Username on Kobo.
#' @param password Password on Kobo.
#' @return This just pushes file. No return. 
#' @export

get_kobo_token = function(server_id, username, password){
 full_url = paste0("https://", server_id, "/token/?format=json")
 res = httr::GET(full_url, httr::authenticate(username, password))
 httr::stop_for_status(res)
 token_json = httr::content(res, "parsed")
 return(token_json$token)  
}
