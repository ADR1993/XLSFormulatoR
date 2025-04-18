#' compile_xlsform function file.
#'
#' @param layer_list A labeled list of network questions to construct.
#' @param filename The name of the external csv file with names and PIDS.
#' @param type The file extension of the photographs. Should be "jpg" or "png".
#' @param photo_confirm A value that specifies whether the photo confirmation group needs to be included in the output. 
#' @param q_list A named list of follow-up questions created using the alter_question() function.
#' Options are "all" (for always), "only_focal" if only confirmation of the focal is needed, and "none" to omit all photo confirmation steps for focal and alters.
#' @return An XLSForm formated "xlxs" file is saved to the working directory This file can be uploaded to KoboCollect. 
#' @export

compile_xlsform = function(layer_list, filename = "names.csv", type = "jpg", photo_confirm = "all", q_list = NULL){
  
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
  
  #create the follow-up groups for each layer
  follow_up_list = vector(mode = "list", length = length(layer_vec))
  for(i in 1:length(layer_vec)){
    follow_up_list[[i]] = layer_details(layer_vec = layer_vec[i], q_list = q_list)
  }
  obj3 = do.call(rbind, follow_up_list)
  
  # Bind together with the focal info group to create the main sheet of the xlsform
  form = rbind(obj1, obj2, obj3)
  
  # Turn it into dataframe for xlsx export
  survey = data.frame(form)
  colnames(survey) = colnames(form)
  
  ### Create the choices sheet of the xlsform
  q_choices = sapply(q_list, function(x) x[[3]])
  
  #if there is at least a choice list provided in the q_list object
  if(any(!sapply(q_choices, is.null)) == TRUE){ 
    
    #choice labels
    choice_label_vec = Filter(Negate(is.null), q_choices)
    choice_label = unlist(choice_label_vec)
    
    #choice names
    choice_name = gsub("\\s+", "_", trimws(choice_label))
    
    #list_name for choices
    list = vector(mode = "list", length = length(choice_label_vec))
    for(i in 1:length(choice_label_vec)){
      list[[i]] = rep(gsub("\\s+", "_", names(choice_label_vec)[i]), length(choice_label_vec[[i]]))
    }
    choice_list_name = paste0(unlist(list), "_scale")
    
    #choices dataframe
    choices = data.frame(choice_list_name, choice_name, choice_label)
    colnames(choices) = c("list_name", "name", "label")
  }
  
  #if no choice list is supplied in the q_list object
  if(any(!sapply(q_choices, is.null)) == FALSE){ 
    choices = data.frame(rbind(rep(NA, 3)))
    colnames(choices) = c("list_name", "name", "label")
  }

  # Create list to turn into xlsform export
  xlsform_list = list(survey = survey,
                      choices = choices)
  
  # Export xlsform to working directory
  writexl::write_xlsx(xlsform_list, "network_collect.xlsx")
}