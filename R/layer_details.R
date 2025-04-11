#' layer_details function file.
#'
#' @param layer_vec The name of the network layer for which the follow-up questions are deployed.
#' @param q_list Follow-up questions list.
#' @return A data frame containing a single layer of follow-up questions in an XLSForm repeat group.
#' @export

layer_details = function(layer_vec, alter_questions){
  
  initial_calc = c("calculate", 
                   paste0(layer_vec, "_string"), 
                   rep(NA, 5),
                   paste0("join(\"\", ${", layer_vec, "_name})"),
                   rep(NA, 2))
  
  begin_repeat = c("begin_repeat",
                   paste0(layer_vec, "_details"), 
                   rep(NA, 3),
                   paste0("string-length(${", layer_vec, "_string}) > 0"),
                   rep(NA, 3),
                   paste0("count(${", layer_vec, "_repeat})"))
  
  calculate1 = c("calculate",
                 paste0("current_", layer_vec, "_label"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_label}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate2 = c("calculate",
                 paste0("current_", layer_vec, "_name"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_name}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate3 = c("calculate",
                 paste0("current_", layer_vec, "_label_out_of_roster"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_by_hand}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate4 = c("calculate", 
                 paste0("current_", layer_vec, "_out_of_roster_indicator"),
                 rep(NA, 5),
                 paste0("if(string-length(${current_", layer_vec, "_label_out_of_roster}) = 0, 0, 1)"),
                 rep(NA, 2))
  
  end_repeat = c("end_repeat",
                   paste0(layer_vec, "_details"), 
                   rep(NA, 8))
  
  #extract question list elements
  q_names = gsub("\\s+", "_", trimws(names(alter_questions))) #question names to use in pasting
  q_prompts = sapply(alter_questions, function(x) x[[1]]) #question prompts to use in pasting
  q_types = sapply(alter_questions, function(x) x[[2]]) #question types to use in pasting
  q_choices = sapply(alter_questions, function(x) x[[3]]) #choice list for select_one and likert questions
  
  #empty list to store follow up questions
  ls = vector(mode = "list", length = length(alter_questions)) 
  
  #loop over question list to add the follow-up questions for each question for the given layer
  for(i in 1:length(alter_questions)){
    
    #if choice list is not supplied
    if(is.null(q_choices[[i]]) == TRUE){
      ls[[i]] = follow_q(layer_vec, q_names[i], q_prompts[i], q_types[i])
    }
    
    #if choice list is supplied
    if(is.null(q_choices[[i]]) == FALSE){
      ls[[i]] = follow_q(layer_vec, q_names[i], q_prompts[i], q_types[i], q_choices[i])
    }
  }
  
  #stack together the followup questions
  followup_df = do.call(rbind, ls) 
  
  df = rbind(initial_calc, begin_repeat, calculate1, calculate2, calculate3, calculate4, followup_df, end_repeat)
  
  return(df)
}