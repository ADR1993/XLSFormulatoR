#' extra_q function file.
#'
#' @param q_name The name of the question (as a string)
#' @param q_prompt The prompt of the question (as a string).
#' @param q_type Question type as a string. The options are "text", "decimal", "select_one", and "likert".
#' @param choice_list A vector of strings that contains the options for a select_one or a likert question. 
#' @return A row with an XLSForm question.
#' @export

extra_q = function(q_name, q_prompt, q_type, choice_list = NULL){
  
  choice = paste0(q_name, "_scale")
  
  if(q_type == "select_one"){
    
    if(is.null(choice_list)){
      stop("Please include a choice list")
    }
    
    #question row for select_one
    row_select = c(paste(q_type, choice), 
               q_name,
               q_prompt,
               NA,
               NA, 
               NA, 
               rep(NA, 4)
    )
    

  }
  
  if(q_type == "likert"){
    
    if(is.null(choice_list)){
      stop("Please include a choice list")
    }
    
    #question row for in-sample people
    row_select = c(paste("select_one", choice), 
               q_name,
               q_prompt,
               NA,
               q_type, 
               NA, 
               rep(NA, 4)
    )
    

  }
  
  #non select, non likert
  if(!q_type %in% c("select_one", "likert")){
    
    #question row for in-sample people
    row_select = c(q_type,
               q_name,
               q_prompt,
               NA,
               NA, 
               NA, 
               rep(NA, 4)
    )
    
  }

  

  return(row_select)
}