#' Function to get a Kobo token.
#'
#' @param url The url for the base server on Kobo.
#' @param username Username on Kobo.
#' @param password Password on Kobo.
#' @return This just pushes file. No return. 
#' @export

get_kobo_token = function(url, username, password){
 full_url = paste0("https://", url, "/token/?format=json")
 res = httr::GET(full_url, httr::authenticate(username, password))
 httr::stop_for_status(res)
 token_json = httr::content(res, "parsed")
 return(token_json$token)  
}
