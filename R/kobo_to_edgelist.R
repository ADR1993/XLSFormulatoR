#' kobo_to_edgelist function file.
#'
#' @param datafile The name of the XLS data object exported from KoboToolbox.
#' @param save If not NULL, then R was save the data with name "save".
#' @return A data frame containing a network edgelist. 
#' @export

 kobo_to_edgelist = function(datafile, save = NULL){
  # Get names of excel sheets 
  sheet_names = readxl::excel_sheets(datafile) 
  repeats = stringr::str_which(sheet_names, "repeat") 
  vec = vector(mode = "list", length = length(repeats)) 

  # Loop 
  for(i in 1:length(repeats)){ 
  vec[[i]] = readxl::read_excel(datafile, sheet = repeats[i]) 
  colnames(vec[[i]]) = c("note", "name", "image_source", "network_layer", "image", 
                         "label", "id_display", "index", "parent_table_name", "parent_index", 
                         "submission_id", "submission_uuid", "submission_time", "submission_validation_status", "submission_notes", 
                         "submission_status", "submission_submitted_by", "submission_version", "submission_tags") } 

  # Bind together the elements of the list 
  d = do.call(rbind, vec) 

  # Rename columns and select 
  d = dplyr::rename(d, alter = name, focal = id_display, layer = network_layer) 
  d = dplyr::select(d, focal, alter, layer) 

  if(!is.null(save)){
    utils::write.csv(d,paste0(save,".csv"))
  }

  return(d)
}
