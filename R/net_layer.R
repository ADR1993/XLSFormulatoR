#' net_layer function file.
#'
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param layer The shortname for the question or network layer.
#' @param layer_question The full question to be read to respodents.
#' @param headers Acessory prompts for internationalization.
#' @return A data frame containing the XLSForm style for one network layer. 
#' @export

net_layer = function(filename, type, layer, layer_question, headers = NULL){
  
  # XLSForm column names
  colnames = c("type", "name", "label", "hint", "appearance", 
               "relevant", "choice_filter", "calculation", "media::image", "repeat_count")
  
  # Error message if the argument is not a character
  if(is.character(filename) == FALSE){
    stop("The filename argument must be a string")
  } else if(is.character(type) == FALSE){
    stop("The type argument must be a string")
  } else if(is.character(layer) == FALSE){
    stop("The layer argument must be a string")
  }
  
  # Begin repeat
  begin_repeat = c("begin_repeat", paste0(layer, "_repeat"), headers[3], rep(NA, length(colnames) - 3))
  
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
                       headers[2], 
                       NA, 
                       "minimal autocomplete", 
                       rep(NA, length(colnames) - 5))
  
  calculate1 = c("calculate", 
                 paste0(layer, "_image_source"), 
                 rep(NA, 5), 
                 paste0("concat(${", layer, "_name}, '.", type, "')"),
                 rep(NA, 2))
  
  end_group1 = c("end_group", 
                 paste0(layer, "_search"),
                 rep(NA, length(colnames) - 2))
  
  # Photo confirmation
  begin_group2 = c("begin_group", 
                   paste0(layer, "_photo_confirmation"), 
                   rep(NA, 2), 
                   "field-list", 
                   paste0("${", layer, "_name} != \"\" and not(selected(${", layer, "_name}, 'out_of_roster'))"),
                   rep(NA, length(colnames) - 6))
  calculate2 = c("calculate", 
                 paste0("network_layer_", layer),
                 rep(NA, 5), 
                 paste0("concat('", layer, "', '')"),
                 rep(NA, 2))
  
  note2 = c("note", paste0(layer, "_image"), rep(NA, 6), paste0("${", layer, "_image_source}"), rep(NA, 1))
  
  calculate3 = c("calculate", 
                 paste0(layer, "_label"), 
                 rep(NA, 5), 
                 paste0("jr:choice-name(${", layer, "_name}, '${", layer, "_name}')"),
                 rep(NA, 2))
  
  calculate4 = c("calculate", 
                 paste0(layer, "_id_display"),
                 rep(NA, 5),
                 "${focal_id}",
                 rep(NA, 2))
  
  end_group2 = c("end_group", 
                 paste0(layer, "_photo_confirmation"), 
                 rep(NA, 3),
                 rep(NA, length(colnames) -5))
  
  begin_group3 = c("begin_group",
                   paste0(layer, "_out_of_roster"),
                   rep(NA, 3),
                   paste0("selected(${", layer, "_name}, 'out_of_roster')"),
                   rep(NA, length(colnames) - 6))
  
  calculate5 = c("calculate", 
                 paste0("network_layer_", layer, "_out"),
                 rep(NA, 5),
                 paste0("concat('", layer, "', '')"),
                 rep(NA, 2))
  
  text = c("text",
           paste0(layer, "_by_hand"), 
           headers[1],
           rep(NA, length(colnames) - 3))

  calculate6 = c("calculate", 
                  paste0(layer, "_hash"), 
                  rep(NA, 5),
                  paste0("digest(${", layer, "_by_hand}, 'SHA-1')"),
                  rep(NA, 2))
  
  calculate7 = c("calculate", 
                 paste0(layer, "_id_display_out"), 
                 rep(NA, 5),
                 "${focal_id}",
                 rep(NA, 2))
  
  end_group3 = c("end_group",
                 paste0(layer, "_out_of_roster"),
                 rep(NA, length(colnames) - 2))
  
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
              
              # group 3 
              begin_group3, 
              calculate5,
              text, 
              calculate6,
              calculate7,
              end_group3,
              
              # ending
              end_repeat
  )
  colnames(out) = colnames
  return(out)
}
