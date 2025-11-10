#' kobo_to_edgelist function file.
#'
#' @param path The name of the XLS data object exported from KoboToolbox.
#' @param questions The labeled list used in the creation of the XLSForm.
#' @param save If TRUE, it saves the output as an XLSX file in the working directory.
#' @return A data frame containing a network edgelist, or a list containing a network edgelist and a hash list for out of roster individuals. 
#' @export

kobo_to_edgelist = function(path, questions, save = FALSE){
  # Extract layer names and repeat group names
  q_name = names(questions)
  q_name_repeat = paste0(q_name, "_repeat")
  
  # List to store repeat groups
  vec = vector(mode = "list", length = length(q_name))
  
  #retrieve repeat groups
  for(i in 1:length(q_name_repeat)){
    vec[[i]] = readxl::read_excel(path, sheet = q_name_repeat[i]) 
  }
  
  # List to store processed edgelists
  ls = vector(mode = "list", length = length(vec))
  
  # Process repeat groups and turn them into edgelists
  for(i in 1:length(vec)){
    ls[[i]] = layer_to_edgelist(vec[[i]], q_name[[i]])
  }
  
  # Join edgelists
  edgelist = do.call(rbind, ls)

  # Saving
  if(save == TRUE){
    writexl::write_xlsx(list(edge_list = edgelist), "edgelist.xlsx")
    
  }
  
  return(edgelist)
}
