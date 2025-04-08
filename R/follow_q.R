#' follow_q function file.
#'
#' @param layer The name of the network layer (as a string).
#' @param q_name The name of the question (as a string)
#' @param q_prompt The prompt of the question (as a string).
#' @param q_type Question type as a string. The options are "text", "decimal", "select_one", and "likert".
#' @param choice_list A vector of strings that contains the options for a select_one or a likert question. 
#' @return A matrix corresponding to the input question in XLSForm format. 
#' @export

follow_q = function(layer, q_name, q_prompt, q_type, choice_list = NULL){
  
  choice = paste0(q_name, "_scale")
  
  if(q_type == "select_one"){
    
    #question row for in-sample people
    row_in = c(paste(q_type, choice), 
               paste0("current_", layer, "_", q_name),
               q_prompt,
               paste0(layer, ": ${current_", layer, "_label}"),
               NA, 
               paste0("${current_", layer, "_out_of_roster_indicator} = 0"), 
               rep(NA, 4)
    )
    
    #question row for out-sample people
    row_out = c(paste(q_type, choice), 
                paste0("current_", layer, "_", q_name, "_out_of_roster"),
                q_prompt,
                paste0(layer, ": ${current_", layer, "_label_out_of_roster}"),
                NA,
                paste0("${current_", layer, "_out_of_roster_indicator} = 1"), 
                rep(NA, 4)
    )
  }
  
  if(q_type == "likert"){
    
    #question row for in-sample people
    row_in = c(paste("select_one", choice), 
               paste0("current_", layer, "_", q_name),
               q_prompt,
               paste0(layer, ": ${current_", layer, "_label}"),
               q_type, 
               paste0("${current_", layer, "_out_of_roster_indicator} = 0"), 
               rep(NA, 4)
    )
    
    #question row for out-sample people
    row_out = c(paste("select_one", choice), 
                paste0("current_", layer, "_", q_name, "_out_of_roster"),
                q_prompt,
                paste0(layer, ": ${current_", layer, "_label_out_of_roster}"),
                q_type,
                paste0("${current_", layer, "_out_of_roster_indicator} = 1"), 
                rep(NA, 4)
    )
  }
  
  #non select, non likert
  if(!q_type %in% c("select_one", "likert")){
    
    #question row for in-sample people
    row_in = c(q_type,
               paste0("current_", layer, "_", q_name),
               q_prompt,
               paste0(layer, ": ${current_", layer, "_label}"),
               NA, 
               paste0("${current_", layer, "_out_of_roster_indicator} = 0"), 
               rep(NA, 4)
    )
    
    #question row for out-sample people
    row_out = c(q_type,
                paste0("current_", layer, "_", q_name, "_out_of_roster"),
                q_prompt,
                paste0(layer, ": ${current_", layer, "_label_out_of_roster}"),
                NA,
                paste0("${current_", layer, "_out_of_roster_indicator} = 1"), 
                rep(NA, 4)
    )
  }
  
  obj = rbind(row_in, row_out)
  return(obj)
}

#function to create a single layer follow-up repeat group
layer_details = function(layer_vec, alter_questions){
  
  begin_repeat = c("begin_repeat",
                   paste0(layer_vec, "_details"), 
                   rep(NA, 7),
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
  
  df = rbind(begin_repeat, calculate1, calculate2, calculate3, calculate4, followup_df, end_repeat)
  
  return(df)
}