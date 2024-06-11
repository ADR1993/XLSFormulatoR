#' focal_info function file.
#'
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @return A data frame containing focal information in the XLSForm style. 
#' @export

focal_info = function(filename, type){
  
  # Error message if the argument is not a character
  if(is.character(filename) == FALSE){
    stop("The filename argument must be a string")
  } else if(is.character(type) == FALSE){
    stop("The type argument must be a string")
  }
  
  # Build XLSForm header
  colnames = c("type", "name", "label", "hint", "appearance", 
               "relevant", "choice_filter", "calculation", "media::image")

  start = c(rep("start", 2), rep(NA, times = length(colnames) - 2))

  end = c(rep("end", 2), rep(NA, times = length(colnames) - 2))

  today = c(rep("today", 2), rep(NA, times = length(colnames) - 2))

  username = c(rep("username", 2), rep(NA, times = length(colnames) - 2))
  
  # Now build focal-info group that depends on external csv file
  begin_group1 = c("begin_group", "focal_info", rep(NA, 2), "field-list", rep(NA, length(colnames) - 5))
  arg1 = c(paste("select_one_from_file", filename),
           "focal_id", "Select name of focal person", NA, "minimal autocomplete", 
           rep(NA, length(colnames) - 5))
  end_group1 = c("end_group", "focal_info", rep(NA, length(colnames) - 2))
  
  # Focal confirmation with picture
  begin_group2 = c("begin_group", 
                    "focal_confirmation", 
                    rep(NA, 2), 
                    "field-list", 
                    rep(NA, length(colnames) - 5))
  row1 = c("calculate", 
            "focal_image_source", 
            rep(NA, 5), 
            paste0("concat(${focal_id}, '.", type, "')"), 
            rep(NA, 1))
  row2 = c("note", "focal_image", rep(NA, 6), "${focal_image_source}")
  row3 = c("note", 
            "focal_id_confirmation", 
            "Confirm the identity of the interviewed person", 
            rep(NA, length(colnames) - 3))
  end_group2 = c("end_group", "focal_confirmation", rep(NA, length(colnames) - 2))
  
  # Output
  table = rbind(start, end, today, username,
                  begin_group1, arg1, end_group1,
                  begin_group2, row1, row2, row3, end_group2)
  colnames(table) = colnames
  return(table)
}

