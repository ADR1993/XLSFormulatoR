#' net_layer function file.
#'
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param layer The shortname for the question or network layer.
#' @param layer_question The full question to be read to respodents..
#' @return A data frame containing the XLSForm style for one network layer. 
#' @export

net_layer = function(filename, type, layer, layer_question){
  
  # XLSForm column names
  colnames = c("type", "name", "label", "hint", "appearance", 
                "relevant", "choice_filter", "calculation", "media::image")
  
  # Error message if the argument is not a character
  if(is.character(filename) == FALSE){
    stop("The filename argument must be a string")
  } else if(is.character(type) == FALSE){
    stop("The type argument must be a string")
  } else if(is.character(layer) == FALSE){
    stop("The layer argument must be a string")
  }
  
  # Begin repeat
  begin_repeat = c("begin_repeat", paste0(layer, "_repeat"), "another person", rep(NA, length(colnames) - 3))
  
  # ID search
  begin_group1 = c("begin_group", 
              paste0(layer, "_search"), 
              rep(NA, 2), 
              "field-list", 
              rep(NA, length(colnames) - 5))

  note1 = c("note", 
             paste0(layer, "_note"), 
             layer_question,
             rep(NA, length(colnames) - 3))

  select_from_file = c(paste("select_one_from_file", filename),
                        paste0(layer, "_name"),
                        "List individuals", 
                        NA, 
                        "minimal autocomplete", 
                        rep(NA, length(colnames) - 5))

  calculate1 = c("calculate", 
                 paste0(layer, "_image_source"), 
                 rep(NA, 5), 
                 paste0("concat(${", layer, "_name}, '.", type, "')"),
                 NA)

  end_group1 = c("end_group", 
                  paste0(layer, "_name"),
                  rep(NA, length(colnames) - 2))
  
  # Photo confirmation
  begin_group2 = c("begin_group", 
                    paste0(layer, "_photo_confirmation"), 
                    rep(NA, 2), 
                    "field-list", 
                    rep(NA, length(colnames) - 5))
  calculate2 = c("calculate", "network_layer", 
                  rep(NA, 5), 
                  paste0("concat('", layer, "', '')"),
                  NA)

  note2 = c("note", paste0(layer, "_image"), rep(NA, 6), paste0("${", layer, "_image_source}"))

  calculate3 = c("calculate", 
                  paste0(layer, "_label"), 
                  rep(NA, 5), 
                  paste0("jr:choice-name(${", layer, "_name}, '${", layer, "_name}')"),
                  NA)

  calculate4 = c("calculate", 
                  paste0(layer, "_id_display"),
                  rep(NA, 5),
                  "${focal_id}",
                  NA)

  end_group2 = c("end_group", 
                  paste0(layer, "_photo_confirmation"), 
                  rep(NA, 2), 
                  "field-list", 
                  rep(NA, length(colnames) - 5))
  
  # End repeat
  end_repeat = c("end_repeat", paste0(layer, "_repeat"), rep(NA, length(colnames) - 2))
  
  # Compile into a data frame structure
  out = rbind(begin_repeat,
               
               # group 1
               begin_group1,
               note1,
               select_from_file,
               calculate1,
               end_group1,
               
               # group2
               begin_group2,
               calculate2,
               note2,
               calculate3,
               calculate4,
               end_group2,
               
               # ending
               end_repeat
               )
  colnames(out) = colnames
  return(out)
}

