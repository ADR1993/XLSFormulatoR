#' kobo_to_edgelist function file.
#'
#' @param path The name of the XLS data object exported from KoboToolbox.
#' @param questions The labeled list used in the creation of the XLSForm.
#' @param save If not NULL, then R was save the data with name "save".
#' @return A data frame containing a network edgelist. 
#' @export

kobo_to_edgelist = function(path, questions, save = NULL){
 # Re-create repeat group names
 q_name = names(questions)
 q_name_repeat = paste0(q_name, "_repeat")

 vec = vector(mode = "list", length = length(q_name))

 for(i in 1:length(q_name_repeat)){ 
  vec[[i]] = read_excel(path, sheet = q_name_repeat[i]) 
  vec[[i]] = vec[[i]][colnames(vec[[i]]) %in% c(paste0(q_name[i], "_name"), paste0(q_name[i], "_id_display"))] 
  vec[[i]]$layer = q_name[i] 
  colnames(vec[[i]]) = c("alter", "focal", "layer") 
   } 

 # Bind together the elements of the list
  d = do.call(rbind, vec) # Reorder the columns 
  d = dplyr::relocate(d, focal, alter, layer) 

 # Save if desired
  if(!is.null(save)){
    utils::write.csv(d,paste0(save,".csv"))
  }
  return(d) 
}


