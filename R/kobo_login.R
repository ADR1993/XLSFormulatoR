#' Function to login to Kobo and get token.
#'
#' @param server_id The url for the Kobo server (no https://).
#' @param username The Kobo username.
#' @param password Password. If NULL, then it can be type interactively to avoid storing the password in the script.
#' @return A token. 
#' @export

kobo_login = function(server_id, username, password=NULL){
  if(is.null(password)){
  password = readline(prompt="Enter your password for KoboToolbox: ")
   }
  api_token = get_kobo_token(server_id = server_id, username = username, password = password)
  password = NULL
  return(api_token)
}
