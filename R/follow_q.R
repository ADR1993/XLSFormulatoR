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
