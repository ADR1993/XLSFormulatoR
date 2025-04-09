#' kobo_to_edgelist function file.
#'
#' @param path The name of the XLS data object exported from KoboToolbox.
#' @param questions The labeled list used in the creation of the XLSForm.
#' @param return_hash Boolean. If TRUE, it returns a list whose first element is the edgelist, and the second element is the hash list mapping out of roster names to their hash. If FALSE, it returns the edgelist only.
#' @param save If TRUE, it saves the output as an XLSX file in the working directory.
#' @return A data frame containing a network edgelist, or a list containing a network edgelist and a hash list for out of roster individuals. 
#' @export

kobo_to_edgelist = function(path, questions, return_hash = TRUE, save = FALSE){
  
  #extract layer names and repeat group names
  q_name = names(questions)
  q_name_repeat = paste0(q_name, "_repeat")
  
  #list to store repeat groups
  vec = vector(mode = "list", length = length(q_name))
  
  #retrieve repeat groups
  for(i in 1:length(q_name_repeat)){
    vec[[i]] = readxl::read_excel(path, sheet = q_name_repeat[i]) 
  }
  
  #list to store processed edgelists
  ls = vector(mode = "list", length = length(vec))
  
  #process repeat groups and turn them into edgelists
  for(i in 1:length(vec)){
    ls[[i]] = layer_to_edgelist(vec[[i]], q_name[[i]])
  }
  
  #join edgelists and hashlists
  edgelist = do.call(rbind, lapply(ls, function(x) x[[1]]))
  hashlist = do.call(rbind, lapply(ls, function(x) x[[2]]))
  
  #create a list with both edgelist and hashlist
  output = list("edge_list" = edgelist, "hash_list" = hashlist)
  
  #conditional outputs
  if(return_hash == FALSE && save == FALSE){
    return(edgelist)
  } 
  if(return_hash == FALSE && save == TRUE){
    writexl::write_xlsx(list(edge_list = edgelist), "edgelist.xlsx")
    return(edgelist)
  } 
  if(return_hash == TRUE && save == FALSE){
    return(output)
  }
  if(return_hash == TRUE && save == TRUE){
    writexl::write_xlsx(output, "edgelist.xlsx")
    return(output)
  }
  if(!return_hash %in% c(TRUE, FALSE)){
    stop("Invalid return_hash argument")
  }
}