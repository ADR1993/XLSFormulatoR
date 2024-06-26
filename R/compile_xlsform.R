#' compile_xlsform function file.
#'
#' @param layer_list A labeled list of network questions to construct.
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param photo_confirm A value that specifies whether the photo confirmation group needs to be included in the output. 
#' Options are "all" (for always), "only_focal" if only confirmation of the focal is needed, and "none" to omit all photo confirmation steps for focal and alters.
#' @return An XLSForm formated "xlxs" file is saved to the working directory This file can be uploaded to KoboCollect. 
#' @export

compile_xlsform = function(layer_list, filename = "names.csv", type = "jpg", photo_confirm = "all"){
  
  if(!photo_confirm %in% c("all", "only_focal", "none")){
    stop("photo_confirm must be one of: all, only_focal, none")
  }

  # Extract layer names and questions from the list
  layer_vec = layer_question = rep(NA, length(layer_list))
  for(i in 1:length(layer_list)){
    layer_vec[i] = names(layer_list)[i]
    layer_question[i] = layer_list[[i]]
  }
  
  
  # List to store the output of the net_layer function
  vec = vector(mode = "list", length = length(layer_list))
  
  # Loop conditionally based on the photo confirmation argument
  if(photo_confirm == "all"){
      obj1 = focal_info(filename, type)

      for(i in 1:length(layer_list)){
    vec[[i]] = net_layer(filename = filename, 
                          layer = layer_vec[i], 
                          layer_question = layer_question[i], 
                          type = type)
       }
  } 

  if(photo_confirm == "only_focal"){  
      obj1 = focal_info(filename, type)

      for(i in 1:length(layer_list)){
        vec[[i]] = net_layer(filename = filename, 
                             layer = layer_vec[i], 
                             layer_question = layer_question[i], 
                             type = type)[-c(7:12),]
      }
  }

  if(photo_confirm == "none"){  
      obj1 = focal_info(filename, type)[-c(9:13),]

      for(i in 1:length(layer_list)){
        vec[[i]] = net_layer(filename = filename, 
                             layer = layer_vec[i], 
                             layer_question = layer_question[i], 
                             type = type)[-c(7:12),]
      }
  }
  
  # Bind all the elements of the vector: this is an object containing all the network questions
  obj2 = do.call(rbind, vec)
  
  # Bind together with the focal info group to create the main sheet of the xlsform
  form = rbind(obj1, obj2)
  
  # Turn it into dataframe for xlsx export
  survey = data.frame(form)
  colnames(survey) = colnames(form)
  
  # Create the choices sheet of the xlsform
  choices = data.frame(rbind(rep(NA, 3)))
  colnames(choices) = c("list_name", "name", "label")
  
  # Create list to turn into xlsform export
  xlsform_list = list(survey = survey,
                       choices = choices)
  
  # Export xlsform to working directory
  writexl::write_xlsx(xlsform_list, "network_collect.xlsx")
}

