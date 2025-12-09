#' layer_details function file.
#'
#' @param layer_vec The name of the network layer for which the follow-up questions are deployed.
#' @param follow_up_questions Follow-up questions list.
#' @param follow_up_type A string: "all", "external", or "none", which controls which follow-up questions get asked.
#' @param headers A list containing info need for skip logic.
#' @param skip_repeat_names If true, allow user to skip repeated names in follow up.
#' @return A data frame containing a single layer of follow-up questions in an XLSForm repeat group.
#' @export

layer_details = function(layer_vec, follow_up_questions, follow_up_type, headers, skip_repeat_names = TRUE){  
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
                 paste0("current_", layer_vec, "_hash"),
                 rep(NA, 5),
                 paste0("indexed-repeat(${", layer_vec, "_hash}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate2 = c("calculate",
                 paste0("current_", layer_vec, "_label"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_label}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate3 = c("calculate",
                 paste0("current_", layer_vec, "_name"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_name}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate4 = c("calculate",
                 paste0("current_", layer_vec, "_label_out_of_roster"),
                 rep(NA, 5), 
                 paste0("indexed-repeat(${", layer_vec, "_by_hand}, ${", layer_vec, "_repeat}, position(..))"),
                 rep(NA, 2))
  
  calculate5 = c("calculate", 
                 paste0("current_", layer_vec, "_out_of_roster_indicator"),
                 rep(NA, 5),
                 paste0("if(string-length(${current_", layer_vec, "_label_out_of_roster}) = 0, 0, 1)"),
                 rep(NA, 2))
  
  end_repeat = c("end_repeat",
                   paste0(layer_vec, "_details"), 
                   rep(NA, 8))

  toggle_prompt_out = extra_q(paste0(layer_vec, "_already_in_set_out_of_roster"), headers[[3]][1], "select_one", 
                          choice_list=c(headers[[3]][2], headers[[3]][3]), 
                          hint=paste0(layer_vec, ": ${current_", layer_vec, "_label_out_of_roster}"),
                          relevant = paste0("${current_", layer_vec, "_out_of_roster_indicator} = 1")
                          )

  toggle_prompt_in = extra_q(paste0(layer_vec, "_already_in_set"), headers[[3]][1], "select_one", 
                          choice_list=c(headers[[3]][2], headers[[3]][3]), 
                          hint=paste0(layer_vec, ": ${current_", layer_vec, "_label}"),
                          relevant = paste0("${current_", layer_vec, "_out_of_roster_indicator} = 0")
                          )

  #extract question list elements
  q_names = gsub("\\s+", "_", trimws(names(follow_up_questions))) #question names to use in pasting
  q_prompts = sapply(follow_up_questions, function(x) x[[1]]) #question prompts to use in pasting
  q_types = sapply(follow_up_questions, function(x) x[[2]]) #question types to use in pasting
  q_choices = sapply(follow_up_questions, function(x) x[[3]]) #choice list for select_one and likert questions
  
  #empty list to store follow up questions
  ls = vector(mode = "list", length = length(follow_up_questions)) 
  
  #loop over question list to add the follow-up questions for each question for the given layer
  for(i in 1:length(follow_up_questions)){
    
    #if choice list is not supplied
    if(is.null(q_choices[[i]]) == TRUE){
      ls[[i]] = follow_q(layer_vec, q_names[i], q_prompts[i], q_types[i], follow_up_type = follow_up_type, skip_repeat_names = skip_repeat_names, headers=headers)
    }
    
    #if choice list is supplied
    if(is.null(q_choices[[i]]) == FALSE){
      ls[[i]] = follow_q(layer_vec, q_names[i], q_prompts[i], q_types[i], q_choices[i], follow_up_type = follow_up_type, skip_repeat_names = skip_repeat_names, headers=headers)
    }
  }
  
  #stack together the followup questions
  followup_df = do.call(rbind, ls) 

  #final row to print focal ID
  print_id = c("calculate", 
    paste0("current_", layer_vec, "_id_display"), 
    rep(NA, 5), 
    "${focal_id}", 
    rep(NA, 2))
  
  if(skip_repeat_names==TRUE){
    if(follow_up_type=="all"){
    df = rbind(initial_calc, begin_repeat, calculate1, calculate2, calculate3, calculate4, calculate5, toggle_prompt_in, toggle_prompt_out, followup_df, print_id, end_repeat)
    }

    if(follow_up_type=="external"){
    df = rbind(initial_calc, begin_repeat, calculate1, calculate2, calculate3, calculate4, calculate5, toggle_prompt_out, followup_df, print_id, end_repeat)   
    }

    } else{
    df = rbind(initial_calc, begin_repeat, calculate1, calculate2, calculate3, calculate4, calculate5, followup_df, print_id, end_repeat)
    }
  
  return(df)
}
