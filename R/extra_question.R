#' extra_question function file.
#'
#' @param prompt The text prompt that will be displayed in the app.
#' @param type The question type. The function supports the following types: "text", "decimal", "select_one", "likert".
#' @param options A vector of possible choices for question types "select_one" and "likert".
#' @return A list containing the question prompt, the question type, and the list of options for "select_one" and "likert" questions.
#' @export

extra_question = function(prompt, type, options = NULL){
  
  if(!type %in% c("text", "decimal", "select_one", "likert")){
    stop("Not a valid type. Valid types: text, decimal, select_one, likert")
  }
  
  ls = list(prompt, type, options)
  return(ls)
}
