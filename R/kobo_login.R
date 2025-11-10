#' Function to login to Kobo and get token.
#'
#' @param url The url for the Kobo server.
#' @param username The Kobo username.
#' @param password Password. If NULL, then it can be type interactively to avoid storing the password in the script.
#' @return A token. 
#' @export

kobo_login = function(url, username, password=NULL){
  if(is.null(password)){
  password = readline(prompt="Enter your password for KoboToolbox: ")
   }
  api_token = KoboconnectR::get_kobo_token(url = url, uname = username, pwd = password)$token
  password = NULL
  return(api_token)
}
